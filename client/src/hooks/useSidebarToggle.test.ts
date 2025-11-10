import { renderHook, act } from '@testing-library/react'
import { useSidebarToggle } from './useSidebarToggle'

describe('useSidebarToggle', () => {
  describe('initialization', () => {
    it('initializes with sidebar closed', () => {
      const { result } = renderHook(() => useSidebarToggle())

      expect(result.current.isOpen).toBe(false)
    })

    it('initializes without hover', () => {
      const { result } = renderHook(() => useSidebarToggle())

      expect(result.current.isHovered).toBe(false)
    })

    it('initializes isOpenOrHovered as false', () => {
      const { result } = renderHook(() => useSidebarToggle())

      expect(result.current.isOpenOrHovered).toBe(false)
    })
  })

  describe('openSidebar', () => {
    it('sets isOpen to true', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
      })

      expect(result.current.isOpen).toBe(true)
    })

    it('sets isOpenOrHovered to true when sidebar opens', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
      })

      expect(result.current.isOpenOrHovered).toBe(true)
    })

    it('can be called multiple times', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.openSidebar()
      })

      expect(result.current.isOpen).toBe(true)
    })
  })

  describe('closeSidebar', () => {
    it('sets isOpen to false', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.closeSidebar()
      })

      expect(result.current.isOpen).toBe(false)
    })

    it('sets isOpenOrHovered to false when sidebar closes and not hovered', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.closeSidebar()
      })

      expect(result.current.isOpenOrHovered).toBe(false)
    })

    it('keeps isOpenOrHovered true when hovering while closing', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseEnter()
        result.current.openSidebar()
        result.current.closeSidebar()
      })

      expect(result.current.isOpenOrHovered).toBe(true)
    })

    it('can be called on already closed sidebar', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.closeSidebar()
      })

      expect(result.current.isOpen).toBe(false)
    })
  })

  describe('handleMouseEnter', () => {
    it('sets isHovered to true', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseEnter()
      })

      expect(result.current.isHovered).toBe(true)
    })

    it('sets isOpenOrHovered to true on hover', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseEnter()
      })

      expect(result.current.isOpenOrHovered).toBe(true)
    })

    it('can be called when sidebar is already open', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.handleMouseEnter()
      })

      expect(result.current.isHovered).toBe(true)
      expect(result.current.isOpen).toBe(true)
    })

    it('can be called multiple times', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseEnter()
        result.current.handleMouseEnter()
      })

      expect(result.current.isHovered).toBe(true)
    })
  })

  describe('handleMouseLeave', () => {
    it('sets isHovered to false', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseEnter()
        result.current.handleMouseLeave()
      })

      expect(result.current.isHovered).toBe(false)
    })

    it('sets isOpenOrHovered to false when not open and no longer hovering', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseEnter()
        result.current.handleMouseLeave()
      })

      expect(result.current.isOpenOrHovered).toBe(false)
    })

    it('keeps isOpenOrHovered true when open but leaving hover', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.handleMouseEnter()
        result.current.handleMouseLeave()
      })

      expect(result.current.isOpenOrHovered).toBe(true)
    })

    it('can be called when not hovered', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseLeave()
      })

      expect(result.current.isHovered).toBe(false)
    })
  })

  describe('state combinations', () => {
    it('handles open + hover state correctly', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.handleMouseEnter()
      })

      expect(result.current.isOpen).toBe(true)
      expect(result.current.isHovered).toBe(true)
      expect(result.current.isOpenOrHovered).toBe(true)
    })

    it('handles open + not hover state correctly', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.handleMouseLeave()
      })

      expect(result.current.isOpen).toBe(true)
      expect(result.current.isHovered).toBe(false)
      expect(result.current.isOpenOrHovered).toBe(true)
    })

    it('handles closed + hover state correctly', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.handleMouseEnter()
      })

      expect(result.current.isOpen).toBe(false)
      expect(result.current.isHovered).toBe(true)
      expect(result.current.isOpenOrHovered).toBe(true)
    })

    it('handles closed + not hover state correctly', () => {
      const { result } = renderHook(() => useSidebarToggle())

      expect(result.current.isOpen).toBe(false)
      expect(result.current.isHovered).toBe(false)
      expect(result.current.isOpenOrHovered).toBe(false)
    })

    it('transitions correctly from open to closed with hover', () => {
      const { result } = renderHook(() => useSidebarToggle())

      act(() => {
        result.current.openSidebar()
        result.current.handleMouseEnter()
      })

      expect(result.current.isOpenOrHovered).toBe(true)

      act(() => {
        result.current.closeSidebar()
      })

      expect(result.current.isOpenOrHovered).toBe(true)

      act(() => {
        result.current.handleMouseLeave()
      })

      expect(result.current.isOpenOrHovered).toBe(false)
    })
  })
})
