import { useLanguage } from '@/contexts/LanguageContext';
import { Button } from '@/components/ui/button';

export function LanguageSwitcher() {
  const { language, setLanguage } = useLanguage();

  const toggleLanguage = () => {
    setLanguage(language === 'fr' ? 'en' : 'fr');
  };

  return (
    <Button
      variant="outline"
      size="icon"
      onClick={toggleLanguage}
      title={language === 'fr' ? 'Switch to English' : 'Passer en Français'}
    >
      <span className="text-lg font-bold">
        {language === 'fr' ? '🇬🇧' : '🇫🇷'}
      </span>
    </Button>
  );
}

export default LanguageSwitcher;