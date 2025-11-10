"use client";

import { Button } from "@/components/ui/button";
import { Sidebar } from "./sidebar";
import { SummaryView } from "./summaryView";
import { TextEditor } from "./textEditor";
import { ThemeToggle } from "./themeToggle";
import { ProjectIntro } from "./projectIntro";
import { AlertCircle, Menu } from "lucide-react";
import { useHomeSummaries } from "@/hooks/useHomeSummaries";
import { useState } from "react";

export function Home() {
  const {
    summaries,
    selectedSummaryId,
    selectedSummary,
    errorMessage,
    showEditor,
    isLoadingSummaries,
    isCreating,
    handleSelectSummary,
    handleSubmitText,
    handleCreateNewSummary,
  } = useHomeSummaries();

  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  return (
    <div className="flex h-screen bg-white dark:bg-black">
      <Sidebar
        Summarys={summaries}
        selectedId={selectedSummaryId}
        onSelectSummary={handleSelectSummary}
        isLoading={isLoadingSummaries}
        isOpen={isSidebarOpen}
        onClose={() => setIsSidebarOpen(false)}
      />

      <main className="flex flex-1 flex-col overflow-hidden">
        <header>
          <div className="flex items-center justify-between p-2 lg:justify-end">
            <button
              onClick={() => setIsSidebarOpen(true)}
              className="rounded p-2 hover:bg-zinc-100 dark:hover:bg-zinc-800 lg:hidden"
              aria-label="Abrir menu"
            >
              <Menu className="h-5 w-5 text-zinc-700 dark:text-zinc-300" />
            </button>
            <ThemeToggle />
          </div>
        </header>

        <div className="flex flex-1 flex-col overflow-y-auto">
          <div className="flex flex-1 flex-col gap-6 px-4 py-6 sm:gap-8 sm:px-6 sm:py-8 lg:px-8">
            {errorMessage && (
              <div className="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 dark:border-red-900/50 dark:bg-red-950/30 dark:text-red-400">
                <AlertCircle className="shrink-0 h-4 w-4" />
                <span>{errorMessage}</span>
              </div>
            )}

            <section className="flex flex-1 flex-col w-full max-w-4xl mx-auto">
              {!showEditor && selectedSummary ? (
                <SummaryView
                  summary={selectedSummary?.summary || null}
                  originalText={selectedSummary?.original_post || null}
                  isLoading={
                    isCreating || selectedSummary?.status === "pending"
                  }
                  resetToggle={showEditor}
                />
              ) : (
                <ProjectIntro />
              )}
            </section>

            <section className="w-full max-w-4xl mx-auto">
              {showEditor ? (
                <TextEditor
                  value=""
                  onSubmit={handleSubmitText}
                  isLoading={isCreating}
                />
              ) : (
                <div className="flex justify-center">
                  <Button
                    onClick={handleCreateNewSummary}
                    size="lg"
                    className="gap-2 w-full sm:w-auto"
                  >
                    Criar novo resumo
                  </Button>
                </div>
              )}
            </section>
          </div>
        </div>
      </main>
    </div>
  );
}
