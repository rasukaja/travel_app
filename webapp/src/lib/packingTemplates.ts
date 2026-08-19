export const PACKING_TEMPLATES: Record<string, string[]> = {
  Basis: [
    'Ausweis / Reisepass',
    'Portemonnaie & Karten',
    'Handy & Ladekabel',
    'Kopfhörer',
    'Zahnbürste & Zahnpasta',
    'Medikamente',
  ],
  Strand: [
    'Badehose / Bikini',
    'Sonnencreme',
    'Sonnenbrille',
    'Handtuch',
    'Flip-Flops',
    'Buch',
  ],
  Business: [
    'Laptop & Netzteil',
    'Anzug / Blazer',
    'Visitenkarten',
    'Präsentationsunterlagen',
    'Hemden/Blusen',
  ],
  Wandern: [
    'Wanderschuhe',
    'Regenjacke',
    'Rucksack',
    'Wasserflasche',
    'Erste-Hilfe-Set',
    'Karte / GPS',
  ],
};

export const PACKING_CATEGORIES = Object.keys(PACKING_TEMPLATES);
