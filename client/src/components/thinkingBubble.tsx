"use client";

import { useEffect, useState } from "react";

type Step = {
  text: string;
  status: "pending" | "typing" | "completed";
  displayText: string;
};

const stepTexts = [
  "Analisando conteúdo",
  "Processando informações",
  "Resumindo pontos principais",
  "Estruturando resposta",
  "Finalizando resumo",
];

type ThinkingBubbleProps = {
  onComplete?: () => void;
};

export function ThinkingBubble({ onComplete }: ThinkingBubbleProps) {
  const [steps, setSteps] = useState<Step[]>(
    stepTexts.map((text) => ({
      text,
      status: "pending" as const,
      displayText: "",
    }))
  );
  const [hasCompleted, setHasCompleted] = useState(false);

  useEffect(() => {
    let currentStepIndex = 0;
    let charIndex = 0;
    let typingInterval: NodeJS.Timeout;

    const typeStep = () => {
      if (currentStepIndex >= steps.length) {
        setHasCompleted(true);
        return;
      }

      const currentStep = stepTexts[currentStepIndex];

      if (charIndex === 0) {
        setSteps((prev) =>
          prev.map((step, idx) =>
            idx === currentStepIndex ? { ...step, status: "typing" } : step
          )
        );
      }

      if (charIndex < currentStep.length) {
        setSteps((prev) =>
          prev.map((step, idx) =>
            idx === currentStepIndex
              ? { ...step, displayText: currentStep.slice(0, charIndex + 1) }
              : step
          )
        );
        charIndex++;
        typingInterval = setTimeout(typeStep, 50);
      } else {
        setSteps((prev) =>
          prev.map((step, idx) =>
            idx === currentStepIndex ? { ...step, status: "completed" } : step
          )
        );
        charIndex = 0;
        currentStepIndex++;
        typingInterval = setTimeout(typeStep, 500);
      }
    };

    typingInterval = setTimeout(typeStep, 300);

    return () => clearTimeout(typingInterval);
  }, []);

  useEffect(() => {
    if (hasCompleted && onComplete) {
      const timer = setTimeout(onComplete, 300);
      return () => clearTimeout(timer);
    }
  }, [hasCompleted, onComplete]);

  return (
    <div className="flex flex-col gap-2 py-4">
      {steps.map((step, index) => (
        <div
          key={index}
          className={`flex items-center gap-2 min-h-6 transition-opacity duration-300 ${
            step.status === "pending" ? "opacity-30" : "opacity-100"
          }`}
        >
          {step.status === "completed" && (
            <span className="text-green-600 dark:text-green-400 shrink-0">✓</span>
          )}
          <span className="text-sm font-medium text-zinc-600 dark:text-zinc-400">
            {step.displayText}
            {step.status === "typing" && (
              <span className="inline-block w-0.5 h-4 ml-1 bg-zinc-600 dark:bg-zinc-400 animate-pulse" />
            )}
          </span>
        </div>
      ))}
    </div>
  );
}
