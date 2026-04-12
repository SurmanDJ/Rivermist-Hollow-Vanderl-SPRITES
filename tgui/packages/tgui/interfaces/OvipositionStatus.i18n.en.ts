const formatTime = (seconds: number): string => {
  if (seconds <= 0) {
    return '0 sec.';
  }
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = Math.round(seconds % 60);
  if (minutes > 0) {
    return `${minutes} min. ${remainingSeconds} sec.`;
  }
  return `${remainingSeconds} sec.`;
};

export default {
  windowTitle: 'My Wombs',
  emptyState: 'No reproductive organs detected.',
  labels: {
    organ: 'ORGAN',
    eggsInside: 'EGGS INSIDE',
    stored: 'Stored',
    clutch: 'Clutch',
    color: 'Color',
    type: 'Type',
    name: 'Name',
    nutrients: 'Nutrients',
    interval: 'Interval',
    resourceDependent: 'Resource Dep',
    limit: 'Limit',
    production: 'Production',
    nextEgg: 'Next egg',
    hatchlingsInside: 'Hatchlings inside',
    stage: 'Stage',
    defaultColor: 'Default',
    fertilized: 'Fertilized',
    by: 'by',
    autoHatch: 'Auto Hatch',
    internalBirth: 'Internal Birth',
    willHatchInside: 'Will hatch inside carrier.',
    on: 'ON',
    off: 'OFF',
    active: 'Active',
    inactive: 'Inactive',
    yes: 'Yes',
    no: 'No',
    unknownStage: '-',
  },
  organNames: {
    ovipositor: 'OVIPOSITOR',
    womb: 'WOMB',
    anus: 'ANUS',
    guts: 'GUTS',
  },
  eggTypes: {
    Normal: 'Normal',
    Spider: 'Spider',
    'Bog Bug': 'Bog Bug',
    Harpy: 'Harpy',
    Embryo: 'Hatchling',
  },
  formatTime,
  formatStatus: (status: string, timeLeft: number): string => {
    if (status === 'ready') {
      return 'Ready.';
    }
    if (status === 'growing') {
      if (timeLeft > 0) {
        return `Ready in ${formatTime(timeLeft)}.`;
      }
      return 'Growing.';
    }
    return 'Dormant.';
  },
};
