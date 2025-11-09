const MIN_CHARACTERS = 300;

export type ValidationError = {
  type: "empty" | "minLength" | "repeatedChars" | "specialCharsOnly";
  message: string;
};

export function validateText(text: string): ValidationError | null {
  const trimmed = text.trim();

  if (!trimmed) {
    return {
      type: "empty",
      message: "Cole ou digite um texto para continuar",
    };
  }

  if (trimmed.length < MIN_CHARACTERS) {
    return {
      type: "minLength",
      message: `O texto deve ter no mínimo ${MIN_CHARACTERS} caracteres`,
    };
  }

  if (isOnlySpecialChars(trimmed)) {
    return {
      type: "specialCharsOnly",
      message: "O texto deve conter mais que apenas caracteres especiais",
    };
  }

  return null;
}

function isOnlySpecialChars(text: string): boolean {
  const alphanumericRegex = /[a-zA-Z0-9]/;
  return !alphanumericRegex.test(text);
}

export function isTextValid(text: string): boolean {
  return validateText(text) === null;
}
