import { useState, useEffect } from "react";

export function useSummaryToggle(shouldReset: boolean) {
  const [showOriginal, setShowOriginal] = useState(false);

  useEffect(() => {
    if (shouldReset) {
      setShowOriginal(false);
    }
  }, [shouldReset]);

  const toggleView = () => {
    setShowOriginal((prev) => !prev);
  };

  return {
    showOriginal,
    toggleView,
  };
}
