import { useState, useCallback } from "react";
import { validateText, type ValidationError } from "@/lib/validations";

type UseTextEditorLogicProps = {
  initialValue?: string;
  onSubmit: (text: string) => void;
};

export function useTextEditorLogic({
  initialValue = "",
  onSubmit,
}: UseTextEditorLogicProps) {
  const [text, setText] = useState(initialValue);
  const [error, setError] = useState<ValidationError | null>(null);

  const handleChange = (newText: string) => {
    setText(newText);
    const validationError = validateText(newText);
    setError(validationError);
  };

  const handleSubmit = useCallback(() => {
    const validationError = validateText(text);
    if (validationError) {
      setError(validationError);
      return;
    }

    onSubmit(text);
    setText("");
    setError(null);
  }, [text, onSubmit]);

  const isValid =
    !error && validateText(text) === null && text.trim().length > 0;

  return {
    text,
    error,
    isValid,
    characterCount: text.length,
    handleChange,
    handleSubmit,
  };
}
