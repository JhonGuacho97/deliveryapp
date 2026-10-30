const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');
const supported = (version) => {
  const [major, minor] = version.trim().split('.').map(Number);
  return major === 24 && minor >= 15;
};

function main() {
  const reference = fs
    .readFileSync(path.join(root, '.node-version'), 'utf8')
    .trim();
  let runtime = process.execPath;
  if (!supported(process.versions.node)) {
    const platform = process.platform === 'win32' ? 'win' : process.platform;
    runtime = path.join(
      root,
      '.tools',
      `node-v${reference}-${platform}-${process.arch}`,
      process.platform === 'win32' ? 'node.exe' : 'bin/node',
    );
    if (!fs.existsSync(runtime))
      throw Error(
        `This backend requires Node 24.15+ (reference ${reference}); the current Node is ${process.versions.node}. Install Node 24 or provide the portable runtime in .tools.`,
      );
    const check = spawnSync(runtime, ['-p', 'process.versions.node'], {
      encoding: 'utf8',
      windowsHide: true,
    });
    if (check.status !== 0 || !supported(check.stdout || ''))
      throw Error('The project Node runtime is not compatible.');
    console.log(`Using project Node ${check.stdout.trim()}.`);
  }
  const [entry, ...args] = process.argv.slice(2);
  if (entry === '--check') {
    const check = spawnSync(runtime, ['--version'], {
      stdio: 'inherit',
      windowsHide: true,
    });
    process.exitCode = check.status ?? 1;
    return;
  }
  if (!entry) throw Error('Specify a Node entry point or --check.');
  const environment = { ...process.env };
  const pathKey =
    Object.keys(environment).find((key) => key.toLowerCase() === 'path') ||
    'PATH';
  const inheritedPath = environment[pathKey] || '';
  for (const key of Object.keys(environment))
    if (key.toLowerCase() === 'path') delete environment[key];
  environment[pathKey] = path.dirname(runtime) + path.delimiter + inheritedPath;
  const result = spawnSync(runtime, [path.resolve(root, entry), ...args], {
    cwd: root,
    env: environment,
    stdio: 'inherit',
    windowsHide: true,
  });
  if (result.error) throw Error('Could not launch the project Node runtime.');
  process.exitCode = result.status ?? 1;
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
