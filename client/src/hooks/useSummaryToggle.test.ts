import { renderHook, act } from '@testing-library/react'
import { useSummaryToggle } from './useSummaryToggle'

describe('useSummaryToggle', () => {
  describe('initialization', () => {
    it('initializes with showOriginal false', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      expect(result.current.showOriginal).toBe(false)
    })

    it('initializes with showOriginal false when shouldReset is true', () => {
      const { result } = renderHook(() => useSummaryToggle(true))

      expect(result.current.showOriginal).toBe(false)
    })
  })

  describe('toggleView', () => {
    it('toggles from false to true', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      act(() => {
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(true)
    })

    it('toggles from true to false', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      act(() => {
        result.current.toggleView()
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(false)
    })

    it('can toggle multiple times', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      act(() => {
        result.current.toggleView() // true
        result.current.toggleView() // false
        result.current.toggleView() // true
        result.current.toggleView() // false
      })

      expect(result.current.showOriginal).toBe(false)
    })
  })

  describe('reset behavior', () => {
    it('resets to false when shouldReset changes to true', () => {
      const { result, rerender } = renderHook(
        ({ shouldReset }) => useSummaryToggle(shouldReset),
        { initialProps: { shouldReset: false } }
      )

      act(() => {
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(true)

      rerender({ shouldReset: true })

      expect(result.current.showOriginal).toBe(false)
    })

    it('does not reset when shouldReset remains false', () => {
      const { result, rerender } = renderHook(
        ({ shouldReset }) => useSummaryToggle(shouldReset),
        { initialProps: { shouldReset: false } }
      )

      act(() => {
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(true)

      rerender({ shouldReset: false })

      expect(result.current.showOriginal).toBe(true)
    })

    it('resets when shouldReset changes from false to true', () => {
      const { result, rerender } = renderHook(
        ({ shouldReset }) => useSummaryToggle(shouldReset),
        { initialProps: { shouldReset: false } }
      )

      act(() => {
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(true)

      rerender({ shouldReset: true })

      expect(result.current.showOriginal).toBe(false)
    })

    it('does not reset when shouldReset remains true', () => {
      const { result, rerender } = renderHook(
        ({ shouldReset }) => useSummaryToggle(shouldReset),
        { initialProps: { shouldReset: true } }
      )

      expect(result.current.showOriginal).toBe(false)

      rerender({ shouldReset: true })

      expect(result.current.showOriginal).toBe(false)
    })

    it('can toggle after reset', () => {
      const { result, rerender } = renderHook(
        ({ shouldReset }) => useSummaryToggle(shouldReset),
        { initialProps: { shouldReset: false } }
      )

      act(() => {
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(true)

      rerender({ shouldReset: true })

      expect(result.current.showOriginal).toBe(false)

      act(() => {
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(true)
    })

    it('handles toggle reset toggle cycle', () => {
      const { result, rerender } = renderHook(
        ({ shouldReset }) => useSummaryToggle(shouldReset),
        { initialProps: { shouldReset: false } }
      )

      // Toggle on
      act(() => {
        result.current.toggleView()
      })
      expect(result.current.showOriginal).toBe(true)

      // Reset
      rerender({ shouldReset: true })
      expect(result.current.showOriginal).toBe(false)

      // Toggle on again
      act(() => {
        result.current.toggleView()
      })
      expect(result.current.showOriginal).toBe(true)
    })
  })

  describe('return value', () => {
    it('returns object with showOriginal and toggleView', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      expect(result.current).toHaveProperty('showOriginal')
      expect(result.current).toHaveProperty('toggleView')
    })

    it('toggleView is a function', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      expect(typeof result.current.toggleView).toBe('function')
    })

    it('showOriginal is a boolean', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      expect(typeof result.current.showOriginal).toBe('boolean')
    })
  })

  describe('edge cases', () => {
    it('handles rapid toggle calls', () => {
      const { result } = renderHook(() => useSummaryToggle(false))

      act(() => {
        for (let i = 0; i < 100; i++) {
          result.current.toggleView()
        }
      })

      expect(result.current.showOriginal).toBe(false)
    })

    it('handles reset followed by rapid toggles', () => {
      const { result, rerender } = renderHook(
        ({ shouldReset }) => useSummaryToggle(shouldReset),
        { initialProps: { shouldReset: false } }
      )

      act(() => {
        result.current.toggleView()
      })

      rerender({ shouldReset: true })

      act(() => {
        result.current.toggleView()
        result.current.toggleView()
        result.current.toggleView()
      })

      expect(result.current.showOriginal).toBe(true)
    })
  })
})
