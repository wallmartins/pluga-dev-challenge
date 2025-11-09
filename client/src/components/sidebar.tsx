"use client";

import { X } from "lucide-react";
import type { Snippet } from "@/lib/types";
import { cn } from "@/lib/utils";
import { useState } from "react";

type SidebarProps = {
  snippets: Snippet[];
  selectedId: string | null;
  onSelectSnippet: (id: string) => void;
  isLoading?: boolean;
  isOpen: boolean;
  onClose: () => void;
};

export function Sidebar({
  snippets,
  selectedId,
  onSelectSnippet,
  isLoading = false,
  isOpen,
  onClose,
}: SidebarProps) {
  const [isHovered, setIsHovered] = useState(false);
  const isOpenOrHovered = isOpen || isHovered;

  const handleSelectSnippet = (id: string) => {
    onSelectSnippet(id);
    onClose();
  };

  return (
    <>
      {isOpen && (
        <div
          className="fixed inset-0 z-30 bg-black/50 lg:hidden"
          onClick={onClose}
        />
      )}

      <aside
        className={cn(
          "fixed left-0 top-0 h-screen bg-white transition-all duration-300 dark:bg-zinc-950",
          isOpen ? "w-64 translate-x-0" : "w-64 -translate-x-full",
          "lg:translate-x-0",
          isOpenOrHovered ? "lg:w-64" : "lg:w-16",
          "lg:border-r lg:border-zinc-100 lg:dark:border-zinc-900",
          isOpenOrHovered &&
            "lg:border-zinc-200 lg:shadow-md lg:dark:border-zinc-800 lg:dark:shadow-lg",
          !isOpenOrHovered &&
            "lg:shadow-sm lg:dark:shadow-md lg:hover:border-zinc-200 lg:dark:hover:border-zinc-800 lg:hover:shadow-md lg:dark:hover:shadow-lg",
          isOpen &&
            "z-40 border-r border-zinc-200 shadow-md dark:border-zinc-800"
        )}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        <div className="flex items-center justify-between px-4 py-4 pr-2">
          <h2
            className={cn(
              "font-semibold text-zinc-900 transition-opacity dark:text-white",
              isOpenOrHovered ? "opacity-100" : "opacity-0"
            )}
          >
            Resumos
          </h2>
          {isOpen && (
            <button
              onClick={onClose}
              className="rounded p-1 hover:bg-zinc-100 dark:hover:bg-zinc-800 lg:hidden"
              aria-label="Fechar menu"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>

        <nav className="overflow-y-auto">
          {isLoading ? (
            <div className="space-y-2 p-4">
              {[...Array(3)].map((_, i) => (
                <div
                  key={i}
                  className="h-12 animate-pulse rounded bg-zinc-200 dark:bg-zinc-800"
                />
              ))}
            </div>
          ) : snippets.length === 0 ? (
            <div className="p-4 text-center text-sm text-zinc-500 dark:text-zinc-400">
              {isOpenOrHovered ? "Nenhum resumo criado" : ""}
            </div>
          ) : (
            <ul className="space-y-1 p-2">
              {snippets.map((snippet) => (
                <li key={snippet.id}>
                  <button
                    onClick={() => handleSelectSnippet(snippet.id)}
                    className={cn(
                      "w-full truncate rounded-md px-3 py-2 text-left text-sm transition-colors",
                      selectedId === snippet.id
                        ? "bg-zinc-200 font-medium text-zinc-900 dark:bg-zinc-800 dark:text-white"
                        : "text-zinc-600 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:bg-zinc-900"
                    )}
                    title={snippet.summary}
                  >
                    {isOpenOrHovered ? (
                      (snippet.summary ?? "Sem resumo").substring(0, 40) + "..."
                    ) : (
                      <span className="invisible">•</span>
                    )}
                  </button>
                </li>
              ))}
            </ul>
          )}
        </nav>
      </aside>

      <div
        className={cn(
          "transition-all duration-300 hidden lg:block shrink-0",
          isOpenOrHovered ? "w-64" : "w-16"
        )}
      />
    </>
  );
}
