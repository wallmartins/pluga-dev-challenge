import { useState, useEffect } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { summariesApi } from "@/lib/api-client";

export function useHomeSummaries() {
  const [selectedSnippetId, setSelectedSnippetId] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [shouldPoll, setShouldPoll] = useState(false);
  const [showEditor, setShowEditor] = useState(true);

  const { data: summaries = [], isLoading: isLoadingSummaries, refetch: refetchSummaries } = useQuery({
    queryKey: ["summaries"],
    queryFn: () => summariesApi.list(),
  });

  const { data: selectedSummary, refetch: refetchSelectedSummary } = useQuery({
    queryKey: ["summary", selectedSnippetId],
    queryFn: () => (selectedSnippetId ? summariesApi.getById(selectedSnippetId) : null),
    enabled: !!selectedSnippetId,
  });

  useEffect(() => {
    if (!shouldPoll || selectedSummary?.status !== "pending") {
      return;
    }

    const interval = setInterval(() => {
      refetchSelectedSummary();
      refetchSummaries();
    }, 1500);

    return () => clearInterval(interval);
  }, [shouldPoll, selectedSummary?.status, refetchSelectedSummary, refetchSummaries]);

  const createSummaryMutation = useMutation({
    mutationFn: (text: string) =>
      summariesApi.create({ summary: { original_post: text } }),
    onSuccess: (newSummary) => {
      setSelectedSnippetId(newSummary.id);
      setErrorMessage(null);
      setShouldPoll(true);
      setShowEditor(false);
      refetchSummaries();
    },
    onError: (error) => {
      const message = error instanceof Error ? error.message : "Erro ao criar resumo";
      setErrorMessage(message);
    },
  });

  const handleSelectSnippet = (id: string) => {
    setSelectedSnippetId(id);
    setShowEditor(false);
    setErrorMessage(null);
  };

  const handleSubmitText = (text: string) => {
    createSummaryMutation.mutate(text);
  };

  const handleCreateNewSummary = () => {
    setShowEditor(true);
    setSelectedSnippetId(null);
    setErrorMessage(null);
    setShouldPoll(false);
  };

  return {
    summaries,
    selectedSnippetId,
    selectedSummary,
    errorMessage,
    showEditor,
    isLoadingSummaries,
    isCreating: createSummaryMutation.isPending,
    handleSelectSnippet,
    handleSubmitText,
    handleCreateNewSummary,
  };
}
