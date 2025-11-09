import { useState } from "react";

export function useSidebarToggle() {
  const [isOpen, setIsOpen] = useState(false);
  const [isHovered, setIsHovered] = useState(false);

  const isOpenOrHovered = isOpen || isHovered;

  const openSidebar = () => {
    setIsOpen(true);
  };

  const closeSidebar = () => {
    setIsOpen(false);
  };

  const handleMouseEnter = () => {
    setIsHovered(true);
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
  };

  return {
    isOpen,
    isHovered,
    isOpenOrHovered,
    openSidebar,
    closeSidebar,
    handleMouseEnter,
    handleMouseLeave,
  };
}
