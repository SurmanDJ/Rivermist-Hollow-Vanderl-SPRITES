import { useBackend } from '../backend';
import {
  Box,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { Window } from '../layouts';

// ---------- Types ----------

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
  // Ovipositor
  egg_capacity?: number;
  clutch_size?: number;
  egg_type_name?: string;
  custom_color?: string | null;
  custom_name?: string;
  resource_dependent?: boolean;
  egg_stage?: number;
  // Womb
  is_egg_layer?: boolean;
  hatchling_count?: number;
  next_egg_seconds?: number;
  interval_seconds?: number;
};

type StatusData = {
  nutriment: number;
  organs: OrganData[];
};

// ---------- Helpers ----------

const fmtTime = (sec: number): string => {
  if (sec <= 0) return '0 sec.';
  const m = Math.floor(sec / 60);
  const s = Math.round(sec % 60);
  if (m > 0) return `${m} min. ${s} sec.`;
  return `${s} sec.`;
};

const statusLabel = (egg: EggData): string => {
  if (egg.status === 'ready') return 'Ready.';
  if (egg.status === 'growing') {
    if (egg.time_left > 0) return `Ready in ${Math.round(egg.time_left)} sec.`;
    return 'Growing.';
  }
  return 'Dormant.';
};

const statusColor = (s: string): string => {
  if (s === 'ready') return 'good';
  if (s === 'growing') return 'average';
  return 'label';
};

// ---------- Main ----------

export const OvipositionStatus = () => {
  const { data } = useBackend<StatusData>();
  const { organs = [], nutriment = 0 } = data;

  return (
    <Window title="Bio-Monitor" width={480} height={640}>
      <Window.Content scrollable>
        {organs.length === 0 ? (
          <Section>
            <Box textAlign="center" color="label" py={4}>
              <Icon name="egg" size={2} mb={2} />
              <br />
              No reproductive organs detected.
            </Box>
          </Section>
        ) : (
          organs.map((organ, i) => (
            <OrganSection key={i} organ={organ} nutriment={nutriment} />
          ))
        )}
      </Window.Content>
    </Window>
  );
};

// ---------- Organ Section ----------

const OrganSection = (props: {
  organ: OrganData;
  nutriment: number;
}) => {
  const { organ, nutriment } = props;
  const isOvi = organ.id === 'ovipositor';
  const isWomb = organ.id === 'womb';

  const countLabel = organ.egg_capacity
    ? `${organ.egg_count}/${organ.egg_capacity}`
    : `${organ.egg_count}`;

  return (
    <Section
      title={
        <Box inline>
          <Icon name={organ.icon} mr={1} />
          {'ORGAN: '}
          {organ.title}
          {' ['}
          {countLabel}
          {']'}
        </Box>
      }
    >
      {isOvi && <OviSummary organ={organ} nutriment={nutriment} />}
      {isWomb && <WombSummary organ={organ} nutriment={nutriment} />}

      {organ.eggs && organ.eggs.length > 0 && (
        <Box mt={1}>
          <Box bold color="label" mb={0.5}>
            EGGS INSIDE:
          </Box>
          {organ.eggs.map((egg, i) => (
            <EggDetail key={i} egg={egg} index={i + 1} />
          ))}
        </Box>
      )}
    </Section>
  );
};

// ---------- Ovipositor Summary ----------

const OviSummary = (props: {
  organ: OrganData;
  nutriment: number;
}) => {
  const { organ, nutriment } = props;
  const stored = organ.egg_count;
  const cap = organ.egg_capacity || 1;

  return (
    <>
      <Box mb={0.5}>
        {'Stored: '}
        <Box inline bold>
          {stored} / {cap}
        </Box>
        {' | Clutch: '}
        <Box inline bold>
          {organ.clutch_size || 1}
        </Box>
      </Box>
      <Box mb={0.5}>
        {organ.custom_color && (
          <>
            {'Color: '}
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
        {'Type: '}
        <Box inline bold>
          {organ.egg_type_name || 'Normal'}
        </Box>
        {organ.custom_name ? (
          <>
            {' | Name: '}
            <Box inline bold>
              {organ.custom_name}
            </Box>
          </>
        ) : null}
      </Box>
      <Box mb={0.5}>
        {'Nutrients: '}
        <Box inline bold>
          {nutriment} u
        </Box>
        {' | Interval: '}
        <Box inline bold>
          {organ.egg_stage !== undefined
            ? `Stage ${organ.egg_stage}/2`
            : '—'}
        </Box>
      </Box>
      {organ.resource_dependent !== undefined && (
        <Box>
          {'Resource Dep: '}
          <Box
            inline
            bold
            color={organ.resource_dependent ? 'good' : 'label'}
          >
            {organ.resource_dependent ? 'ON' : 'OFF'}
          </Box>
        </Box>
      )}
    </>
  );
};

// ---------- Womb Summary ----------

const WombSummary = (props: {
  organ: OrganData;
  nutriment: number;
}) => {
  const { organ, nutriment } = props;
  const cap = organ.egg_capacity || 0;
  const nxt = organ.next_egg_seconds ?? 0;

  return (
    <>
      <Box mb={0.5}>
        {cap > 0 && (
          <>
            {'Limit: '}
            <Box inline bold>
              {organ.egg_count} / {cap}
            </Box>
            {' | '}
          </>
        )}
        {'Production: '}
        <Box
          inline
          bold
          color={organ.is_egg_layer ? 'good' : 'label'}
        >
          {organ.is_egg_layer ? 'Active' : 'Inactive'}
        </Box>
        {' | Nutrients: '}
        <Box inline bold>
          {nutriment} u
        </Box>
      </Box>
      {nxt > 0 && (
        <Box mb={0.5}>
          {'Next egg: '}
          <Box inline bold>
            {fmtTime(nxt)}
          </Box>
        </Box>
      )}
      {organ.resource_dependent && (
        <Box mb={0.5}>
          {'Resource Dep: '}
          <Box inline bold color="good">
            ON
          </Box>
        </Box>
      )}
      {(organ.hatchling_count ?? 0) > 0 && (
        <Box mb={0.5} bold color="bad">
          <Icon name="baby" mr={0.5} />
          {'Hatchlings inside: '}
          {organ.hatchling_count}
        </Box>
      )}
    </>
  );
};

// ---------- Egg Detail ----------

const EggDetail = (props: { egg: EggData; index: number }) => {
  const { egg, index } = props;
  const pct = egg.progress_pct;
  const sLabel = statusLabel(egg);
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
      {/* Line 1: index. name (type)   [color squares] */}
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>
            {index}. {egg.name} ({egg.type_name})
          </Box>
        </Stack.Item>
        <Stack.Item>
          <ColorSquares color={egg.display_color} />
        </Stack.Item>
      </Stack>

      {/* Line 2: Color: #hex          Stage X/Y */}
      <Stack>
        <Stack.Item grow>
          <Box color="label" fontSize="0.9em">
            {'Color: '}
            {egg.color_hex || 'Default'}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box fontSize="0.9em">
            Stage {egg.stage}/{egg.max_stage}
          </Box>
        </Stack.Item>
      </Stack>

      {/* Line 3: progress bar        status text */}
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

      {/* Line 4+: special info */}
      {egg.has_preg && egg.fertilized && (
        <Box fontSize="0.85em" color="average" mt={0.3}>
          <Icon name="heart" mr={0.5} />
          {'Fertilized'}
          {egg.father_name ? ` by ${egg.father_name}` : ''}
        </Box>
      )}
      {egg.hatch_inside && (
        <Box fontSize="0.85em" color="average" mt={0.2} italic>
          * Will hatch inside carrier.
        </Box>
      )}
      {egg.has_preg &&
        (egg.auto_hatch !== undefined || egg.hatch_inside) && (
          <Box fontSize="0.85em" color="label" mt={0.2}>
            {'Auto Hatch: '}
            {egg.auto_hatch ? 'Yes' : 'No'}
            {'. Internal Birth: '}
            {egg.hatch_inside ? 'Yes' : 'No'}
            {'.'}
          </Box>
        )}
    </Box>
  );
};

// ---------- Color Squares ----------

const ColorSquares = (props: { color: string | null }) => {
  const { color } = props;
  if (!color) return null;
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
