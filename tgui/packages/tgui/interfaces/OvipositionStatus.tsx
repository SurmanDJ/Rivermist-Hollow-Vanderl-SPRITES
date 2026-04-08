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

type EggData = {
  name: string;
  egg_type: string;
  custom_color: string | null;
  growing: boolean;
  stage?: number;
  max_stage?: number;
  fertilized?: boolean;
  laid?: boolean;
  ready?: boolean;
  hatch_inside?: boolean;
};

type SectionData = {
  type: string;
  title: string;

  // Ovipositor fields
  eggs_stored?: number;
  max_stored?: number;
  clutch_size?: number;
  resource_dependent?: boolean;
  nutriment?: number;
  custom_name?: string;
  custom_color?: string;

  // Womb fields
  is_egg_layer?: boolean;
  egg_count?: number;
  egg_limit?: number;
  next_egg_seconds?: number;
  interval_seconds?: number;
  hatchling_count?: number;

  // Common
  eggs: EggData[];
};

type OvipositionStatusData = {
  sections: SectionData[];
};

export const OvipositionStatus = () => {
  const { data } = useBackend<OvipositionStatusData>();
  const { sections = [] } = data;

  return (
    <Window title="Egg Status" width={380} height={500}>
      <Window.Content scrollable>
        {sections.length === 0 ? (
          <Section>
            <Box textAlign="center" color="label" py={4} fontSize="1.1em">
              <Icon name="egg" size={2} mb={2} />
              <br />
              I don&apos;t sense any eggs inside me.
            </Box>
          </Section>
        ) : (
          sections.map((section, i) => (
            <SectionPanel key={i} section={section} />
          ))
        )}
      </Window.Content>
    </Window>
  );
};

const SectionPanel = (props: { section: SectionData }) => {
  const { section } = props;

  const sectionIcon =
    section.type === 'ovipositor'
      ? 'mars'
      : section.type === 'womb'
        ? 'venus'
        : 'circle';

  return (
    <Section
      title={
        <Box inline>
          <Icon name={sectionIcon} mr={1} />
          {section.title}
        </Box>
      }
    >
      {section.type === 'ovipositor' && (
        <OvipositorPanel section={section} />
      )}
      {section.type === 'womb' && <WombPanel section={section} />}
      {section.type === 'other' && <OtherPanel section={section} />}

      {section.eggs && section.eggs.length > 0 && (
        <Box mt={1}>
          <Box bold mb={0.5} color="label">
            <Icon name="egg" mr={1} />
            Eggs ({section.eggs.length})
          </Box>
          {section.eggs.map((egg, i) => (
            <EggCard key={i} egg={egg} />
          ))}
        </Box>
      )}
    </Section>
  );
};

const OvipositorPanel = (props: { section: SectionData }) => {
  const { section } = props;
  const stored = section.eggs_stored ?? 0;
  const max = section.max_stored ?? 1;

  return (
    <LabeledList>
      <LabeledList.Item label="Eggs Stored">
        <ProgressBar
          value={stored}
          maxValue={max}
          ranges={{
            good: [0, max * 0.6],
            average: [max * 0.6, max * 0.9],
            bad: [max * 0.9, max],
          }}
        >
          {stored} / {max}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Clutch Size">
        {section.clutch_size}
      </LabeledList.Item>
      {section.resource_dependent && (
        <LabeledList.Item label="Nutriment">
          <ProgressBar
            value={section.nutriment ?? 0}
            maxValue={5}
            ranges={{
              bad: [0, 1],
              average: [1, 3],
              good: [3, 5],
            }}
          >
            {section.nutriment ?? 0} / 5
          </ProgressBar>
        </LabeledList.Item>
      )}
      {section.custom_name && (
        <LabeledList.Item label="Egg Style">
          <Box inline>
            {section.custom_color && (
              <Box
                inline
                width="12px"
                height="12px"
                mr={1}
                style={{
                  backgroundColor: section.custom_color,
                  borderRadius: '50%',
                  display: 'inline-block',
                  verticalAlign: 'middle',
                }}
              />
            )}
            {section.custom_name}
          </Box>
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};

const WombPanel = (props: { section: SectionData }) => {
  const { section } = props;
  const eggCount = section.egg_count ?? 0;
  const eggLimit = section.egg_limit ?? 3;
  const nextEgg = section.next_egg_seconds ?? 0;
  const interval = section.interval_seconds ?? 1;

  return (
    <LabeledList>
      {section.is_egg_layer && (
        <>
          <LabeledList.Item label="Production">
            <Box inline color="green" bold>
              <Icon name="circle" size={0.8} mr={0.5} />
              Active
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Capacity">
            <ProgressBar
              value={eggCount}
              maxValue={eggLimit}
              ranges={{
                good: [0, eggLimit * 0.6],
                average: [eggLimit * 0.6, eggLimit * 0.9],
                bad: [eggLimit * 0.9, eggLimit],
              }}
            >
              {eggCount} / {eggLimit}
            </ProgressBar>
          </LabeledList.Item>
          {nextEgg > 0 && (
            <LabeledList.Item label="Next Egg">
              <ProgressBar
                value={interval - nextEgg}
                maxValue={interval}
                color="blue"
              >
                {Math.ceil(nextEgg / 60)}m remaining
              </ProgressBar>
            </LabeledList.Item>
          )}
          {section.resource_dependent && (
            <LabeledList.Item label="Nutriment">
              <ProgressBar
                value={section.nutriment ?? 0}
                maxValue={10}
                ranges={{
                  bad: [0, 2],
                  average: [2, 5],
                  good: [5, 10],
                }}
              >
                {section.nutriment ?? 0}
                {(section.nutriment ?? 0) <= 0 ? ' — paused!' : ''}
              </ProgressBar>
            </LabeledList.Item>
          )}
        </>
      )}
      {(section.hatchling_count ?? 0) > 0 && (
        <LabeledList.Item label="Hatchlings">
          <Box color="red" bold>
            <Icon name="baby" mr={0.5} />
            {section.hatchling_count} inside
          </Box>
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};

const OtherPanel = (props: { section: SectionData }) => {
  const { section } = props;
  return (
    <LabeledList>
      <LabeledList.Item label="Eggs">
        {section.eggs?.length ?? 0}
      </LabeledList.Item>
    </LabeledList>
  );
};

const EggCard = (props: { egg: EggData }) => {
  const { egg } = props;
  const stage = egg.stage ?? 0;
  const maxStage = egg.max_stage ?? 4;
  const progress = maxStage > 0 ? stage / maxStage : 0;

  let statusColor = 'label';
  let statusText = 'Dormant';
  let statusIcon = 'moon';

  if (egg.growing) {
    if (egg.ready) {
      statusColor = egg.hatch_inside ? 'red' : 'orange';
      statusText = egg.hatch_inside ? 'Hatching inside!' : 'Ready to lay!';
      statusIcon = egg.hatch_inside ? 'burst' : 'check-circle';
    } else {
      statusColor = egg.fertilized ? 'green' : 'blue';
      statusText = egg.fertilized ? 'Growing' : 'Developing';
      statusIcon = 'seedling';
    }
  }

  return (
    <Box
      mb={0.5}
      p={0.8}
      style={{
        background: 'rgba(255,255,255,0.03)',
        borderRadius: '3px',
        border: '1px solid rgba(255,255,255,0.08)',
      }}
    >
      <Stack align="center">
        <Stack.Item>
          <Box
            width="16px"
            height="16px"
            mr={1}
            style={{
              backgroundColor: egg.custom_color || '#a0a080',
              borderRadius: '50%',
              border: '1px solid rgba(255,255,255,0.2)',
            }}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Box bold fontSize="1.05em">
            {egg.name}
          </Box>
          {egg.growing && (
            <ProgressBar
              value={stage}
              maxValue={maxStage}
              mt={0.3}
              ranges={{
                blue: [0, maxStage * 0.5],
                teal: [maxStage * 0.5, maxStage * 0.9],
                green: [maxStage * 0.9, maxStage],
              }}
            >
              Stage {stage}/{maxStage}
            </ProgressBar>
          )}
        </Stack.Item>
        <Stack.Item>
          <Box
            color={statusColor}
            textAlign="right"
            fontSize="0.9em"
          >
            <Icon name={statusIcon} mr={0.5} />
            {statusText}
          </Box>
          {egg.growing && egg.fertilized !== undefined && (
            <Box
              color={egg.fertilized ? 'green' : 'label'}
              textAlign="right"
              fontSize="0.8em"
              mt={0.2}
            >
              {egg.fertilized ? '♀ Fertilized' : '○ Unfertilized'}
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Box>
  );
};
