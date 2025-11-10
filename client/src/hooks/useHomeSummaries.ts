import { useState, useEffect } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { summariesApi } from "@/lib/api-client";

export function useHomeSummaries() {
  const [selectedSummaryId, setSelectedSummaryId] = useState<string | null>(
    null
  );
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [shouldPoll, setShouldPoll] = useState(false);
  const [showEditor, setShowEditor] = useState(true);

  const {
    data: allSummaries = [],
    isLoading: isLoadingSummaries,
    refetch: refetchSummaries,
  } = useQuery({
    queryKey: ["summaries"],
    queryFn: () => summariesApi.list(),
  });

  const summaries = allSummaries.filter(
    (summary) => summary.status !== "failed"
  );

  const { data: selectedSummary, refetch: refetchSelectedSummary } = useQuery({
    queryKey: ["summary", selectedSummaryId],
    queryFn: () =>
      selectedSummaryId ? summariesApi.getById(selectedSummaryId) : null,
    enabled: !!selectedSummaryId,
  });

  useEffect(() => {
    if (!shouldPoll || !selectedSummary) {
      return;
    }

    if (selectedSummary.status === "failed") {
      setErrorMessage(
        selectedSummary.summary || "Falha ao criar o resumo. Tente novamente."
      );
      setShouldPoll(false);
      return;
    }

    if (selectedSummary.status !== "pending") {
      setShouldPoll(false);
      setErrorMessage(null);
      return;
    }

    const interval = setInterval(() => {
      refetchSelectedSummary();
      refetchSummaries();
    }, 1500);

    return () => clearInterval(interval);
  }, [shouldPoll, selectedSummary, refetchSelectedSummary, refetchSummaries]);

  const createSummaryMutation = useMutation({
    mutationFn: (text: string) =>
      summariesApi.create({ summary: { original_post: text } }),
    onSuccess: (newSummary) => {
      if (newSummary?.id) {
        setSelectedSummaryId(newSummary.id);
        setErrorMessage(null);
        setShouldPoll(true);
        setShowEditor(false);
        refetchSummaries();
      }
    },
    onError: (error) => {
      const message =
        error instanceof Error ? error.message : "Erro ao criar resumo";
      setErrorMessage(message);
    },
  });

  const handleSelectSummary = (id: string) => {
    setSelectedSummaryId(id);
    setShowEditor(false);
    setErrorMessage(null);
  };

  const handleSubmitText = (text: string) => {
    createSummaryMutation.mutate(text);
  };

  const handleCreateNewSummary = () => {
    setShowEditor(true);
    setSelectedSummaryId(null);
    setErrorMessage(null);
    setShouldPoll(false);
  };

  return {
    summaries,
    selectedSummaryId,
    selectedSummary,
    errorMessage,
    showEditor,
    isLoadingSummaries,
    isCreating: createSummaryMutation.isPending,
    handleSelectSummary,
    handleSubmitText,
    handleCreateNewSummary,
  };
}
