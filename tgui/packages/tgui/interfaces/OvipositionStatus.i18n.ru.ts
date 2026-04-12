const formatTime = (seconds: number): string => {
  if (seconds <= 0) {
    return '0 сек.';
  }
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = Math.round(seconds % 60);
  if (minutes > 0) {
    return `${minutes} мин. ${remainingSeconds} сек.`;
  }
  return `${remainingSeconds} сек.`;
};

export default {
  windowTitle: 'My Wombs',
  emptyState: 'Репродуктивные органы не обнаружены.',
  labels: {
    organ: 'ОРГАН',
    eggsInside: 'ЯЙЦА ВНУТРИ',
    stored: 'Запас',
    clutch: 'Кладка',
    color: 'Цвет',
    type: 'Тип',
    name: 'Имя',
    nutrients: 'Питание',
    interval: 'Интервал',
    resourceDependent: 'Зависит от ресурсов',
    limit: 'Лимит',
    production: 'Производство',
    nextEgg: 'Следующее яйцо',
    hatchlingsInside: 'Детенышей внутри',
    stage: 'Стадия',
    defaultColor: 'По умолчанию',
    fertilized: 'Оплодотворено',
    by: 'от',
    autoHatch: 'Автовылупление',
    internalBirth: 'Внутреннее рождение',
    willHatchInside: 'Вылупится внутри носителя.',
    on: 'ВКЛ',
    off: 'ВЫКЛ',
    active: 'Активно',
    inactive: 'Неактивно',
    yes: 'Да',
    no: 'Нет',
    unknownStage: '-',
  },
  organNames: {
    ovipositor: 'ЯЙЦЕКЛАД',
    womb: 'МАТКА',
    anus: 'АНУС',
    guts: 'ЖИВОТ',
  },
  eggTypes: {
    Normal: 'Обычное',
    Spider: 'Паучье',
    'Bog Bug': 'Болотного жука',
    Harpy: 'Гарпии',
    Embryo: 'Эмбрион',
  },
  formatTime,
  formatStatus: (status: string, timeLeft: number): string => {
    if (status === 'ready') {
      return 'Готово.';
    }
    if (status === 'growing') {
      if (timeLeft > 0) {
        return `Готово через ${formatTime(timeLeft)}.`;
      }
      return 'Растет.';
    }
    return 'Спит.';
  },
};
