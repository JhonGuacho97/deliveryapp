const fs = require('node:fs');
const path = require('node:path');
const { spawn, execFileSync } = require('node:child_process');

// Stop/status must also work after a failed build has removed dist.
const environment = path.resolve(__dirname, '../.env');
if (fs.existsSync(environment)) process.loadEnvFile(environment);

const root = path.resolve(__dirname, '..');
const local = path.join(root, '.local');
const statePath = path.join(local, 'backend-process.json');
const entry = path.join(root, 'dist/main.js');
const port = Number(process.env.PORT || 3000);
const url = `http://localhost:${port}/api`;

function managedProcess() {
  if (!fs.existsSync(statePath)) return null;
  const state = JSON.parse(fs.readFileSync(statePath, 'utf8'));
  if (
    !Number.isInteger(state.pid) ||
    state.pid <= 0 ||
    state.entryPoint !== entry
  )
    return null;
  try {
    if (process.platform === 'win32') {
      const command = `Get-CimInstance Win32_Process -Filter "ProcessId=${state.pid}" | Select-Object ExecutablePath,CommandLine | ConvertTo-Json -Compress`;
      const details = JSON.parse(
        execFileSync(
          'powershell.exe',
          ['-NoProfile', '-NonInteractive', '-Command', command],
          { encoding: 'utf8', windowsHide: true },
        ),
      );
      if (
        !details ||
        details.ExecutablePath?.toLowerCase() !==
          process.execPath.toLowerCase() ||
        !details.CommandLine?.includes(entry)
      )
        return null;
    } else {
      const command = execFileSync(
        'ps',
        ['-p', String(state.pid), '-o', 'command='],
        { encoding: 'utf8' },
      );
      if (!command.includes(entry)) return null;
    }
    process.kill(state.pid, 0);
    return state;
  } catch {
    return null;
  }
}

async function main() {
  const action = process.argv[2] || 'status';
  if (!['start', 'stop', 'status'].includes(action))
    throw new Error('Expected start, stop or status.');
  const existing = managedProcess();
  if (action === 'stop') {
    if (existing) {
      process.kill(existing.pid);
      console.log(`Local backend stopped (PID ${existing.pid}).`);
    } else
      console.log('No managed backend is running; no process was stopped.');
    if (fs.existsSync(statePath)) fs.unlinkSync(statePath);
    return;
  }
  if (existing) {
    console.log(`Local backend running: ${url} (PID ${existing.pid}).`);
    return;
  }
  if (action === 'status') {
    console.log('Local backend is stopped.');
    return;
  }
  const dataSource = require('../dist/database/data-source').default;
  if (
    process.env.NODE_ENV !== 'development' ||
    !['localhost', '127.0.0.1', '::1'].includes(dataSource.options.host)
  ) {
    throw new Error(
      'This launcher is only for a local development environment.',
    );
  }
  const net = require('node:net');
  await new Promise((resolve, reject) => {
    const probe = net.createServer();
    probe.once('error', () =>
      reject(
        new Error(`Port ${port} is already in use. No process was stopped.`),
      ),
    );
    probe.listen(port, '127.0.0.1', () => probe.close(resolve));
  });
  fs.mkdirSync(local, { recursive: true });
  const out = fs.openSync(path.join(local, 'backend.stdout.log'), 'a');
  const err = fs.openSync(path.join(local, 'backend.stderr.log'), 'a');
  const child = spawn(process.execPath, [entry], {
    cwd: root,
    env: process.env,
    detached: true,
    windowsHide: true,
    stdio: ['ignore', out, err],
  });
  fs.closeSync(out);
  fs.closeSync(err);
  child.on('error', (error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
  child.unref();
  fs.writeFileSync(
    statePath,
    JSON.stringify(
      {
        pid: child.pid,
        entryPoint: entry,
        port,
        startedAt: new Date().toISOString(),
      },
      null,
      2,
    ) + '\n',
    { mode: 0o600 },
  );
  const deadline = Date.now() + 30000;
  while (Date.now() < deadline) {
    try {
      const response = await fetch(`${url}/client/market/orders`, {
        signal: AbortSignal.timeout(1000),
      });
      if (response.status === 401) {
        console.log(`Local backend ready: ${url} (PID ${child.pid}).`);
        return;
      }
    } catch {}
    if (child.exitCode !== null)
      throw new Error(
        'Backend exited. Review .local/backend.stderr.log and .local/backend.stdout.log.',
      );
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  throw new Error(
    'Startup has not completed. Review the local logs and use local:status.',
  );
}
main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
