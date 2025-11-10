import { validateText, isTextValid } from './validations'

describe('validations', () => {
  describe('validateText', () => {
    it('returns error for empty text', () => {
      const result = validateText('')
      expect(result).toEqual({
        type: 'empty',
        message: 'Cole ou digite um texto para continuar',
      })
    })

    it('returns error for text with only whitespace', () => {
      const result = validateText('   \n\t  ')
      expect(result).toEqual({
        type: 'empty',
        message: 'Cole ou digite um texto para continuar',
      })
    })

    it('returns error for text below minimum characters', () => {
      const result = validateText('short text')
      expect(result?.type).toBe('minLength')
      expect(result?.message).toContain('300 caracteres')
    })

    it('returns error for text with only special characters', () => {
      const result = validateText('!@#$%^&*()_+-=[]{}|;:,.<>?')
      expect(result).not.toBeNull()
      expect(result?.type).toBe('minLength')
    })

    it('returns null for valid text', () => {
      const validText = 'a'.repeat(300)
      const result = validateText(validText)
      expect(result).toBeNull()
    })

    it('returns null for text with exactly minimum characters', () => {
      const validText = 'a'.repeat(300)
      const result = validateText(validText)
      expect(result).toBeNull()
    })

    it('returns null for text with special characters and alphanumeric', () => {
      const validText = 'This is valid text ' + 'a'.repeat(282) + ' with some special chars !@#'
      const result = validateText(validText)
      expect(result).toBeNull()
    })

    it('returns null for text with numbers and special characters', () => {
      const validText = '123 This is valid text ' + 'a'.repeat(280)
      const result = validateText(validText)
      expect(result).toBeNull()
    })

    it('handles text with only numbers', () => {
      const validText = '1234567890'.repeat(30)
      const result = validateText(validText)
      expect(result).toBeNull()
    })

    it('handles unicode characters correctly', () => {
      const validText = 'Açúcar é bom ' + 'a'.repeat(287)
      const result = validateText(validText)
      expect(result).toBeNull()
    })

    it('handles mixed case text correctly', () => {
      const validText = 'AbCdEfGh ' + 'a'.repeat(291)
      const result = validateText(validText)
      expect(result).toBeNull()
    })

    it('returns error for special chars only with spaces', () => {
      const result = validateText('!@# $%^ &*()')
      expect(result).not.toBeNull()
      expect(result?.type).toBe('minLength')
    })

    it('returns error for text with only special characters meeting min length', () => {
      const specialCharsText = '!@#$%^&*()'.repeat(30)
      const result = validateText(specialCharsText)
      expect(result).toEqual({
        type: 'specialCharsOnly',
        message: 'O texto deve conter mais que apenas caracteres especiais',
      })
    })
  })

  describe('isTextValid', () => {
    it('returns true for valid text', () => {
      const validText = 'a'.repeat(300)
      expect(isTextValid(validText)).toBe(true)
    })

    it('returns false for empty text', () => {
      expect(isTextValid('')).toBe(false)
    })

    it('returns false for short text', () => {
      expect(isTextValid('short')).toBe(false)
    })

    it('returns false for special chars only', () => {
      expect(isTextValid('!@#$%^&*()')).toBe(false)
    })

    it('returns false for whitespace only', () => {
      expect(isTextValid('   \n\t  ')).toBe(false)
    })

    it('returns true for long text with alphanumeric', () => {
      const longText = 'Valid text content ' + 'a'.repeat(282)
      expect(isTextValid(longText)).toBe(true)
    })
  })
})
