import { Box, Icon, ProgressBar, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type EggData = {
  name: string;
  type_name: string;
  display_color: string | null;
  color_hex: string | null;
  has_preg: boolean;
  stage: number;
  max_stage: number;
  progress_pct: number;
  fertilized?: boolean;
  hatch_inside?: boolean;
  auto_hatch?: boolean;
  mother_name?: string;
  father_name?: string;
  status: string;
  time_left: number;
};

type OrganData = {
  id: string;
  title: string;
  icon: string;
  egg_count: number;
  eggs: EggData[];
  egg_capacity?: number;
  clutch_size?: number;
  egg_type_name?: string;
  custom_color?: string | null;
  custom_name?: string;
  resource_dependent?: boolean;
  egg_stage?: number;
  is_egg_layer?: boolean;
  hatchling_count?: number;
  next_egg_seconds?: number;
  interval_seconds?: number;
};

type StatusData = {
  nutriment: number;
  organs: OrganData[];
};

export type OvipositionStatusLocale = {
  windowTitle: string;
  emptyState: string;
  labels: {
    organ: string;
    eggsInside: string;
    stored: string;
    clutch: string;
    color: string;
    type: string;
    name: string;
    nutrients: string;
    interval: string;
    resourceDependent: string;
    limit: string;
    production: string;
    nextEgg: string;
    hatchlingsInside: string;
    stage: string;
    defaultColor: string;
    fertilized: string;
    by: string;
    autoHatch: string;
    internalBirth: string;
    willHatchInside: string;
    on: string;
    off: string;
    active: string;
    inactive: string;
    yes: string;
    no: string;
    unknownStage: string;
  };
  organNames: Record<string, string>;
  eggTypes: Record<string, string>;
  formatTime: (seconds: number) => string;
  formatStatus: (status: string, timeLeft: number) => string;
};

const statusColor = (status: string): string => {
  if (status === 'ready') {
    return 'good';
  }
  if (status === 'growing') {
    return 'average';
  }
  return 'label';
};

const resolveOrganName = (locale: OvipositionStatusLocale, organ: OrganData) =>
  locale.organNames[organ.id] || locale.organNames[organ.title] || organ.title;

const resolveEggType = (
  locale: OvipositionStatusLocale,
  typeName?: string | null,
) => {
  if (!typeName) {
    return locale.eggTypes.Normal || 'Normal';
  }
  return locale.eggTypes[typeName] || typeName;
};

export const OvipositionStatusView = (props: {
  locale: OvipositionStatusLocale;
}) => {
  const { locale } = props;
  const { data } = useBackend<StatusData>();
  const { organs = [], nutriment = 0 } = data;

  return (
    <Window title={locale.windowTitle} width={480} height={640}>
      <Window.Content scrollable>
        {organs.length === 0 ? (
          <Section>
            <Box textAlign="center" color="label" py={4}>
              <Icon name="egg" size={2} mb={2} />
              <br />
              {locale.emptyState}
            </Box>
          </Section>
        ) : (
          organs.map((organ, i) => (
            <OrganSection
              key={i}
              organ={organ}
              nutriment={nutriment}
              locale={locale}
            />
          ))
        )}
      </Window.Content>
    </Window>
  );
};

const OrganSection = (props: {
  organ: OrganData;
  nutriment: number;
  locale: OvipositionStatusLocale;
}) => {
  const { organ, nutriment, locale } = props;
  const isOvi = organ.id === 'ovipositor';
  const isWomb = organ.id === 'womb';
  const organTitle = resolveOrganName(locale, organ);

  const countLabel = organ.egg_capacity
    ? `${organ.egg_count}/${organ.egg_capacity}`
    : `${organ.egg_count}`;

  return (
    <Section
      title={
        <Box inline>
          <Icon name={organ.icon} mr={1} />
          {locale.labels.organ}
          {': '}
          {organTitle}
          {' ['}
          {countLabel}
          {']'}
        </Box>
      }
    >
      {isOvi && (
        <OviSummary organ={organ} nutriment={nutriment} locale={locale} />
      )}
      {isWomb && (
        <WombSummary organ={organ} nutriment={nutriment} locale={locale} />
      )}

      {organ.eggs && organ.eggs.length > 0 && (
        <Box mt={1}>
          <Box bold color="label" mb={0.5}>
            {locale.labels.eggsInside}
            {':'}
          </Box>
          {organ.eggs.map((egg, i) => (
            <EggDetail key={i} egg={egg} index={i + 1} locale={locale} />
          ))}
        </Box>
      )}
    </Section>
  );
};

const OviSummary = (props: {
  organ: OrganData;
  nutriment: number;
  locale: OvipositionStatusLocale;
}) => {
  const { organ, nutriment, locale } = props;
  const stored = organ.egg_count;
  const cap = organ.egg_capacity || 1;

  return (
    <>
      <Box mb={0.5}>
        {locale.labels.stored}
        {': '}
        <Box inline bold>
          {stored} / {cap}
        </Box>
        {' | '}
        {locale.labels.clutch}
        {': '}
        <Box inline bold>
          {organ.clutch_size || 1}
        </Box>
      </Box>
      <Box mb={0.5}>
        {organ.custom_color && (
          <>
            {locale.labels.color}
            {': '}
            <Box inline bold color="label">
              {organ.custom_color}
            </Box>
            <Box
              inline
              ml={0.5}
              style={{
                width: '10px',
                height: '10px',
                backgroundColor: organ.custom_color,
                border: '1px solid rgba(255,255,255,0.3)',
                display: 'inline-block',
                verticalAlign: 'middle',
              }}
            />
            {' | '}
          </>
        )}
        {locale.labels.type}
        {': '}
        <Box inline bold>
          {resolveEggType(locale, organ.egg_type_name)}
        </Box>
        {organ.custom_name ? (
          <>
            {' | '}
            {locale.labels.name}
            {': '}
            <Box inline bold>
              {organ.custom_name}
            </Box>
          </>
        ) : null}
      </Box>
      <Box mb={0.5}>
        {locale.labels.nutrients}
        {': '}
        <Box inline bold>
          {nutriment} u
        </Box>
        {' | '}
        {locale.labels.interval}
        {': '}
        <Box inline bold>
          {organ.egg_stage !== undefined
            ? `${locale.labels.stage} ${organ.egg_stage}/2`
            : locale.labels.unknownStage}
        </Box>
      </Box>
      {organ.resource_dependent !== undefined && (
        <Box>
          {locale.labels.resourceDependent}
          {': '}
          <Box inline bold color={organ.resource_dependent ? 'good' : 'label'}>
            {organ.resource_dependent ? locale.labels.on : locale.labels.off}
          </Box>
        </Box>
      )}
    </>
  );
};

const WombSummary = (props: {
  organ: OrganData;
  nutriment: number;
  locale: OvipositionStatusLocale;
}) => {
  const { organ, nutriment, locale } = props;
  const cap = organ.egg_capacity || 0;
  const nxt = organ.next_egg_seconds ?? 0;

  return (
    <>
      <Box mb={0.5}>
        {cap > 0 && (
          <>
            {locale.labels.limit}
            {': '}
            <Box inline bold>
              {organ.egg_count} / {cap}
            </Box>
            {' | '}
          </>
        )}
        {locale.labels.production}
        {': '}
        <Box inline bold color={organ.is_egg_layer ? 'good' : 'label'}>
          {organ.is_egg_layer ? locale.labels.active : locale.labels.inactive}
        </Box>
        {' | '}
        {locale.labels.nutrients}
        {': '}
        <Box inline bold>
          {nutriment} u
        </Box>
      </Box>
      {nxt > 0 && (
        <Box mb={0.5}>
          {locale.labels.nextEgg}
          {': '}
          <Box inline bold>
            {locale.formatTime(nxt)}
          </Box>
        </Box>
      )}
      {organ.resource_dependent && (
        <Box mb={0.5}>
          {locale.labels.resourceDependent}
          {': '}
          <Box inline bold color="good">
            {locale.labels.on}
          </Box>
        </Box>
      )}
      {(organ.hatchling_count ?? 0) > 0 && (
        <Box mb={0.5} bold color="bad">
          <Icon name="baby" mr={0.5} />
          {locale.labels.hatchlingsInside}
          {': '}
          {organ.hatchling_count}
        </Box>
      )}
    </>
  );
};

const EggDetail = (props: {
  egg: EggData;
  index: number;
  locale: OvipositionStatusLocale;
}) => {
  const { egg, index, locale } = props;
  const pct = egg.progress_pct;
  const sLabel = locale.formatStatus(egg.status, egg.time_left);
  const sColor = statusColor(egg.status);

  return (
    <Box
      mb={1}
      ml={1}
      style={{
        borderLeft: '2px solid rgba(255,255,255,0.15)',
        paddingLeft: '8px',
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>
            {index}. {egg.name} ({resolveEggType(locale, egg.type_name)})
          </Box>
        </Stack.Item>
        <Stack.Item>
          <ColorSquares color={egg.display_color} />
        </Stack.Item>
      </Stack>

      <Stack>
        <Stack.Item grow>
          <Box color="label" fontSize="0.9em">
            {locale.labels.color}
            {': '}
            {egg.color_hex || locale.labels.defaultColor}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box fontSize="0.9em">
            {locale.labels.stage} {egg.stage}/{egg.max_stage}
          </Box>
        </Stack.Item>
      </Stack>

      <Stack align="center" mt={0.3}>
        <Stack.Item grow>
          <ProgressBar
            value={pct}
            maxValue={100}
            ranges={{
              bad: [0, 25],
              average: [25, 75],
              good: [75, 100],
            }}
          />
        </Stack.Item>
        <Stack.Item ml={1}>
          <Box bold color={sColor} fontSize="0.9em">
            {sLabel}
          </Box>
        </Stack.Item>
      </Stack>

      {egg.has_preg && egg.fertilized && (
        <Box fontSize="0.85em" color="average" mt={0.3}>
          <Icon name="heart" mr={0.5} />
          {locale.labels.fertilized}
          {egg.father_name ? ` ${locale.labels.by} ${egg.father_name}` : ''}
        </Box>
      )}
      {egg.hatch_inside && (
        <Box fontSize="0.85em" color="average" mt={0.2} italic>
          * {locale.labels.willHatchInside}
        </Box>
      )}
      {egg.has_preg && (egg.auto_hatch !== undefined || egg.hatch_inside) && (
        <Box fontSize="0.85em" color="label" mt={0.2}>
          {locale.labels.autoHatch}
          {': '}
          {egg.auto_hatch ? locale.labels.yes : locale.labels.no}
          {'. '}
          {locale.labels.internalBirth}
          {': '}
          {egg.hatch_inside ? locale.labels.yes : locale.labels.no}
          {'.'}
        </Box>
      )}
    </Box>
  );
};

const ColorSquares = (props: { color: string | null }) => {
  const { color } = props;
  if (!color) {
    return null;
  }
  return (
    <Stack>
      {[1, 0.65, 0.35].map((opacity, i) => (
        <Stack.Item key={i} mr={i < 2 ? 0.2 : 0}>
          <Box
            inline
            style={{
              width: '10px',
              height: '10px',
              backgroundColor: color,
              opacity,
              border: '1px solid rgba(255,255,255,0.15)',
            }}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};
