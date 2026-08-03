import type {
  AcpSessionConfigOption,
  AcpSessionConfigValue,
  AcpSessionModelOption,
} from '@/infrastructure/api/service-api/ACPClientAPI';

const FAST_MODE_CONFIG_ID = 'fast-mode';
const FAST_MODE_ON_VALUE = 'on';
const FAST_MODE_OFF_VALUE = 'off';

export interface AcpFastModeState {
  option: AcpSessionConfigOption;
  enabled: boolean;
}

export function resolveAcpFastModeState(
  options: AcpSessionConfigOption[],
): AcpFastModeState | null {
  const option = options.find(candidate => candidate.id === FAST_MODE_CONFIG_ID);
  if (!option) return null;

  if (option.type === 'boolean') {
    return { option, enabled: option.currentValue };
  }

  const values = new Set(option.options.map(candidate => candidate.value));
  if (!values.has(FAST_MODE_ON_VALUE) || !values.has(FAST_MODE_OFF_VALUE)) {
    return null;
  }
  if (option.currentValue !== FAST_MODE_ON_VALUE && option.currentValue !== FAST_MODE_OFF_VALUE) {
    return null;
  }

  return {
    option,
    enabled: option.currentValue === FAST_MODE_ON_VALUE,
  };
}

export function buildAcpFastModeValue(
  option: AcpSessionConfigOption,
  enabled: boolean,
): AcpSessionConfigValue | null {
  if (option.type === 'boolean') {
    return { type: 'boolean', value: enabled };
  }

  const value = enabled ? FAST_MODE_ON_VALUE : FAST_MODE_OFF_VALUE;
  return option.options.some(candidate => candidate.value === value)
    ? { type: 'select', value }
    : null;
}

export function getAcpModelProviderName(model: AcpSessionModelOption): string | undefined {
  return normalizedProviderName(model.providerName)
    ?? providerNameFromProviderQualifiedValue(model.description)
    ?? providerNameFromProviderQualifiedValue(model.id);
}

function normalizedProviderName(value: string | undefined): string | undefined {
  const trimmed = value?.trim();
  return trimmed ? trimmed : undefined;
}

function providerNameFromProviderQualifiedValue(value: string | undefined): string | undefined {
  const trimmed = value?.trim();
  if (!trimmed) return undefined;

  const slashIndex = trimmed.indexOf('/');
  if (slashIndex <= 0 || slashIndex === trimmed.length - 1) return undefined;

  const provider = trimmed.slice(0, slashIndex).trim();
  const modelId = trimmed.slice(slashIndex + 1).trim();
  return provider && modelId ? provider : undefined;
}
