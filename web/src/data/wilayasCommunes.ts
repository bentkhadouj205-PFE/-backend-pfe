/** Subset of wilayas / communes for selects (extend as needed). */
export const WILAYAS_COMMUNES: Record<string, string[]> = {
  Adrar: ['ADRAR', 'Aoulef', 'Reggane', 'Timimoun', 'Zaouiet Kounta'],
  Alger: ['Alger Centre', 'Bab El Oued', 'Hydra', 'Kouba', 'Dar El Beïda'],
  Oran: ['Oran', 'Bir El Djir', 'Es Senia', 'Arzew'],
  Constantine: ['Constantine', 'El Khroub', 'Aïn Smara'],
  Annaba: ['Annaba', 'El Bouni', 'Sidi Amar'],
};

export const WILAYA_NAMES = Object.keys(WILAYAS_COMMUNES).sort((a, b) => a.localeCompare(b, 'fr'));

export function communesForWilaya(wilaya: string): string[] {
  return WILAYAS_COMMUNES[wilaya] ?? [];
}
