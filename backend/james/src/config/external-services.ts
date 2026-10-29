import { ServiceUnavailableException } from '@nestjs/common';

export function externalServicesEnabled(): boolean {
  return process.env.EXTERNAL_SERVICES_ENABLED !== 'false';
}

export function requireExternalServices(): void {
  if (!externalServicesEnabled()) {
    throw new ServiceUnavailableException(
      'External services are disabled in this local environment.',
    );
  }
}
