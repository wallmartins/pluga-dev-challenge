import { renderHook, act } from '@testing-library/react'
import { useTextEditorLogic } from './useTextEditorLogic'

describe('useTextEditorLogic', () => {
  describe('initialization', () => {
    it('initializes with empty text by default', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      expect(result.current.text).toBe('')
      expect(result.current.error).toBeNull()
      expect(result.current.characterCount).toBe(0)
    })

    it('initializes with provided initial value', () => {
      const initialValue = 'Initial text content'
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue,
          onSubmit: jest.fn(),
        })
      )

      expect(result.current.text).toBe(initialValue)
      expect(result.current.characterCount).toBe(initialValue.length)
    })

    it('initializes with no error when text is valid', () => {
      const validText = 'a'.repeat(300)
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: validText,
          onSubmit: jest.fn(),
        })
      )

      expect(result.current.error).toBeNull()
    })

    it('initializes isValid as false for empty text', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      expect(result.current.isValid).toBe(false)
    })

    it('initializes without explicit initialValue parameter', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          onSubmit: jest.fn(),
        })
      )

      expect(result.current.text).toBe('')
      expect(result.current.error).toBeNull()
      expect(result.current.characterCount).toBe(0)
    })
  })

  describe('handleChange', () => {
    it('updates text when user types', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleChange('New text')
      })

      expect(result.current.text).toBe('New text')
    })

    it('updates character count when text changes', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      const testText = 'Test text with 24 chars'
      act(() => {
        result.current.handleChange(testText)
      })

      expect(result.current.characterCount).toBe(testText.length)
    })

    it('sets error for text below minimum length', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleChange('short')
      })

      expect(result.current.error).not.toBeNull()
      expect(result.current.error?.type).toBe('minLength')
    })

    it('clears error for valid text', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      const validText = 'a'.repeat(300)
      act(() => {
        result.current.handleChange(validText)
      })

      expect(result.current.error).toBeNull()
    })

    it('sets error for special characters only', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleChange('!@#$%^&*()')
      })

      expect(result.current.error).not.toBeNull()
      expect(result.current.error?.type).toBe('minLength')
    })

    it('sets isValid to false when error exists', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleChange('short')
      })

      expect(result.current.isValid).toBe(false)
    })

    it('sets isValid to true for valid text', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      const validText = 'a'.repeat(300)
      act(() => {
        result.current.handleChange(validText)
      })

      expect(result.current.isValid).toBe(true)
    })
  })

  describe('handleSubmit', () => {
    it('calls onSubmit with text when valid', () => {
      const onSubmit = jest.fn()
      const validText = 'a'.repeat(300)

      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: validText,
          onSubmit,
        })
      )

      act(() => {
        result.current.handleSubmit()
      })

      expect(onSubmit).toHaveBeenCalledWith(validText)
    })

    it('clears text after successful submit', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: 'a'.repeat(300),
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleSubmit()
      })

      expect(result.current.text).toBe('')
    })

    it('clears error after successful submit', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: 'a'.repeat(300),
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleSubmit()
      })

      expect(result.current.error).toBeNull()
    })

    it('does not call onSubmit when text is invalid', () => {
      const onSubmit = jest.fn()

      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: 'short',
          onSubmit,
        })
      )

      act(() => {
        result.current.handleSubmit()
      })

      expect(onSubmit).not.toHaveBeenCalled()
    })

    it('sets error when trying to submit invalid text', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleSubmit()
      })

      expect(result.current.error).not.toBeNull()
    })

    it('does not clear text when submit fails', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: 'short',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleSubmit()
      })

      expect(result.current.text).toBe('short')
    })
  })

  describe('edge cases', () => {
    it('handles text with only whitespace', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleChange('   \n\t  ')
      })

      expect(result.current.error).not.toBeNull()
      expect(result.current.isValid).toBe(false)
    })

    it('handles very long text', () => {
      const longText = 'a'.repeat(10000)
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: longText,
          onSubmit: jest.fn(),
        })
      )

      expect(result.current.characterCount).toBe(10000)
      expect(result.current.isValid).toBe(true)
    })

    it('handles unicode characters correctly', () => {
      const unicodeText = 'Açúcar é muito bom ' + 'a'.repeat(281)
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      act(() => {
        result.current.handleChange(unicodeText)
      })

      expect(result.current.isValid).toBe(true)
    })

    it('handles rapid consecutive changes', () => {
      const { result } = renderHook(() =>
        useTextEditorLogic({
          initialValue: '',
          onSubmit: jest.fn(),
        })
      )

      const validText = 'a'.repeat(300)
      act(() => {
        result.current.handleChange('s')
        result.current.handleChange('sh')
        result.current.handleChange('sho')
        result.current.handleChange(validText)
      })

      expect(result.current.text).toBe(validText)
      expect(result.current.isValid).toBe(true)
    })
  })
})
