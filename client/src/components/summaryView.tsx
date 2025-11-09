"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { ThinkingBubble } from "@/components/thinkingBubble";
import { ProjectIntro } from "@/components/projectIntro";
import { cn } from "@/lib/utils";
import { useSummaryToggle } from "@/hooks/useSummaryToggle";

type SummaryViewProps = {
  summary: string | null;
  originalText: string | null;
  isLoading?: boolean;
  resetToggle?: boolean;
};

export function SummaryView({
  summary,
  originalText,
  isLoading = false,
  resetToggle = false,
}: SummaryViewProps) {
  const { showOriginal, toggleView } = useSummaryToggle(resetToggle ?? false);
  const [showContent, setShowContent] = useState(false);
  const [animationComplete, setAnimationComplete] = useState(false);
  const [wasLoadingBefore, setWasLoadingBefore] = useState(false);

  useEffect(() => {
    if (isLoading) {
      setWasLoadingBefore(true);
      setShowContent(false);
      setAnimationComplete(false);
    } else if (!isLoading && summary) {
      if (wasLoadingBefore) {
        if (animationComplete) {
          setShowContent(true);
        }
      } else {
        setShowContent(true);
      }
    }
  }, [isLoading, summary, animationComplete, wasLoadingBefore]);

  const isEmpty = !summary && !originalText;
  const displayText = showOriginal ? originalText : summary;
  const buttonLabel = showOriginal ? "Resumo" : "Original";

  const handleAnimationComplete = () => {
    setAnimationComplete(true);
    if (summary) {
      setShowContent(true);
    }
  };

  const shouldShowThinkingBubble = isLoading || (!showContent && summary && wasLoadingBefore);

  return (
    <div className="flex flex-col gap-3 sm:gap-4">
      {(summary || originalText) && (
        <div className="flex justify-center">
          <Button
            variant="outline"
            size="sm"
            onClick={toggleView}
            className="border-zinc-300 dark:border-zinc-700 w-full sm:w-auto"
          >
            {buttonLabel}
          </Button>
        </div>
      )}

      <div
        className={cn(
          "rounded-lg border border-zinc-200 bg-zinc-50 p-4 sm:p-6 dark:border-zinc-800 dark:bg-zinc-900/50 transition-opacity duration-300",
          isEmpty
            ? "flex items-center justify-center min-h-80 sm:min-h-96"
            : "min-h-32"
        )}
      >
        {shouldShowThinkingBubble && (
          <div className="animate-in fade-in duration-300">
            <ThinkingBubble onComplete={handleAnimationComplete} />
          </div>
        )}

        {!isLoading && isEmpty && (
          <div className="animate-in fade-in duration-300 w-full">
            <ProjectIntro />
          </div>
        )}

        {!shouldShowThinkingBubble && showContent && displayText && (
          <p className="animate-in fade-in duration-300 whitespace-pre-wrap text-sm sm:text-base text-zinc-900 dark:text-zinc-50">
            {displayText}
          </p>
        )}
      </div>
    </div>
  );
}
