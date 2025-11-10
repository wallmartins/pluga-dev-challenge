"use client";

import { useState, useEffect, useCallback } from "react";
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
  const [previousSummary, setPreviousSummary] = useState<string | null>(null);

  useEffect(() => {
    if (summary !== previousSummary) {
      setPreviousSummary(summary);

      if (!isLoading && summary) {
        setShowContent(true);
        setAnimationComplete(true);
        setWasLoadingBefore(false);
      }
    }
  }, [summary, previousSummary, isLoading]);

  useEffect(() => {
    if (isLoading && !summary) {
      setWasLoadingBefore(true);
      setShowContent(false);
      setAnimationComplete(false);
    } else if (summary && !isLoading) {
      if (wasLoadingBefore && !animationComplete) {
        return;
      }
      setShowContent(true);
      setWasLoadingBefore(false);
    }
  }, [isLoading, summary, animationComplete, wasLoadingBefore]);

  const isEmpty = !summary && !originalText;
  const displayText = showOriginal ? originalText : summary;
  const buttonLabel = showOriginal ? "Resumo" : "Original";

  const handleAnimationComplete = useCallback(() => {
    setAnimationComplete(true);
    setShowContent(true);
  }, []);

  const shouldShowThinkingBubble = (isLoading && !summary) || (wasLoadingBefore && !animationComplete && summary);

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
          <div className="animate-in fade-in duration-300" key="thinking-bubble">
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
