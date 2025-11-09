"use client";

import { Button } from "@/components/ui/button";
import { Send, AlertCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import { useTextEditorLogic } from "@/hooks/useTextEditorLogic";

type TextEditorProps = {
  value: string;
  onSubmit: (text: string) => void;
  isLoading?: boolean;
};

export function TextEditor({
  value,
  onSubmit,
  isLoading = false,
}: TextEditorProps) {
  const { text, error, isValid, characterCount, handleChange, handleSubmit } =
    useTextEditorLogic({ initialValue: value, onSubmit });

  return (
    <div className="flex flex-col gap-3">
      {error && (
        <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 dark:border-red-900/50 dark:bg-red-950/30 dark:text-red-400">
          <AlertCircle className="h-4 w-4 shrink-0" />
          <span>{error.message}</span>
        </div>
      )}

      <textarea
        value={text}
        onChange={(e) => handleChange(e.target.value)}
        placeholder="Cole ou digite aqui o texto que deseja resumir"
        className={cn(
          "max-h-96 min-h-40 sm:min-h-32 w-full resize-none rounded-lg border bg-white p-3 sm:p-4 font-mono text-sm outline-none transition-colors",
          error
            ? "border-red-300 dark:border-red-700"
            : "border-zinc-200 hover:border-zinc-300 focus:border-zinc-400 dark:border-zinc-800 dark:hover:border-zinc-700 dark:focus:border-zinc-600",
          "dark:bg-zinc-900 dark:text-zinc-50 dark:placeholder-zinc-500"
        )}
        disabled={isLoading}
      />

      {characterCount > 0 && (
        <div className="text-right text-xs text-zinc-500 dark:text-zinc-400">
          {characterCount} caracteres
        </div>
      )}

      <div className="flex justify-center sm:justify-end">
        <Button
          onClick={handleSubmit}
          disabled={!isValid || isLoading}
          size="lg"
          className="gap-2 w-full sm:w-auto"
        >
          <Send className="h-4 w-4" />
          Resumir
        </Button>
      </div>
    </div>
  );
}
