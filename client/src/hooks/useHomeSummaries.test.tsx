import { renderHook, act, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactNode } from "react";
import { useHomeSummaries } from "./useHomeSummaries";
import { summariesApi } from "@/lib/api-client";
import type { Summary } from "@/lib/types";

jest.mock("@/lib/api-client");

const mockSummariesApi = summariesApi as jest.Mocked<typeof summariesApi>;

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  const Wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
  Wrapper.displayName = "QueryClientWrapper";
  return Wrapper;
};

const createMockSummary = (overrides?: Partial<Summary>): Summary => ({
  id: "test-id",
  text: "Test text",
  summary: "Test summary",
  original_post: "Original post",
  status: "completed",
  ...overrides,
});

describe("useHomeSummaries", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.useFakeTimers();
  });

  afterEach(() => {
    act(() => {
      jest.runOnlyPendingTimers();
    });
    jest.useRealTimers();
  });

  describe("initialization", () => {
    it("initializes with default values", async () => {
      mockSummariesApi.list.mockResolvedValue([]);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.selectedSummaryId).toBeNull();
        expect(result.current.errorMessage).toBeNull();
        expect(result.current.showEditor).toBe(true);
      });
    });

    it("loads summaries on mount", async () => {
      const mockSummaries: Summary[] = [
        createMockSummary({
          id: "1",
          status: "completed",
          summary: "Test summary 1",
        }),
        createMockSummary({
          id: "2",
          status: "failed",
          summary: "Test summary 2",
        }),
      ];
      mockSummariesApi.list.mockResolvedValue(mockSummaries);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      expect(result.current.summaries).toHaveLength(1);
      expect(result.current.summaries[0].id).toBe("1");
    });

    it("filters out failed summaries", async () => {
      const mockSummaries: Summary[] = [
        createMockSummary({ id: "1", status: "completed", summary: "Good" }),
        createMockSummary({ id: "2", status: "failed", summary: "Bad" }),
        createMockSummary({ id: "3", status: "pending", summary: "" }),
      ];
      mockSummariesApi.list.mockResolvedValue(mockSummaries);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.summaries).toHaveLength(2);
      });

      expect(result.current.summaries).not.toContainEqual(
        expect.objectContaining({ id: "2", status: "failed" })
      );
    });
  });

  describe("handleSelectSummary", () => {
    it("sets selected Summary id", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({ id: "Summary-123", status: "completed" })
      );

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSelectSummary("Summary-123");
      });

      expect(result.current.selectedSummaryId).toBe("Summary-123");
    });

    it("hides editor when selecting Summary", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({ id: "Summary-123", status: "completed" })
      );

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSelectSummary("Summary-123");
      });

      expect(result.current.showEditor).toBe(false);
    });

    it("clears error message when selecting Summary", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({ id: "Summary-123", status: "completed" })
      );

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSelectSummary("Summary-123");
      });

      expect(result.current.errorMessage).toBeNull();
    });
  });

  describe("handleSubmitText", () => {
    it("creates summary with submitted text", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      const newSummary = createMockSummary({
        id: "new-id",
        status: "pending",
        original_post: "Lorem ipsum dolor sit amet",
      });
      mockSummariesApi.create.mockResolvedValue(newSummary);
      mockSummariesApi.getById.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Lorem ipsum dolor sit amet");
      });

      await waitFor(() => {
        expect(mockSummariesApi.create).toHaveBeenCalledWith({
          summary: { original_post: "Lorem ipsum dolor sit amet" },
        });
      });
    });

    it("sets selected Summary after successful creation", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      const newSummary = createMockSummary({
        id: "new-id",
        status: "pending",
      });
      mockSummariesApi.create.mockResolvedValue(newSummary);
      mockSummariesApi.getById.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.selectedSummaryId).toBe("new-id");
      });
    });

    it("hides editor after successful creation", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      const newSummary = createMockSummary({
        id: "new-id",
        status: "pending",
      });
      mockSummariesApi.create.mockResolvedValue(newSummary);
      mockSummariesApi.getById.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.showEditor).toBe(false);
      });
    });

    it("sets error message on creation failure", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      const error = new Error("Network error");
      mockSummariesApi.create.mockRejectedValue(error);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.errorMessage).toBe("Network error");
      });
    });

    it("clears editor on successful creation", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      const newSummary = createMockSummary({
        id: "new-id",
        status: "pending",
      });
      mockSummariesApi.create.mockResolvedValue(newSummary);
      mockSummariesApi.getById.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleCreateNewSummary();
      });

      expect(result.current.showEditor).toBe(true);

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.showEditor).toBe(false);
      });
    });
  });

  describe("handleCreateNewSummary", () => {
    it("shows editor", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({ id: "Summary-123", status: "completed" })
      );

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSelectSummary("Summary-123");
      });

      act(() => {
        result.current.handleCreateNewSummary();
      });

      expect(result.current.showEditor).toBe(true);
    });

    it("clears selected Summary id", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({ id: "Summary-123", status: "completed" })
      );

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSelectSummary("Summary-123");
      });

      act(() => {
        result.current.handleCreateNewSummary();
      });

      expect(result.current.selectedSummaryId).toBeNull();
    });

    it("clears error message", async () => {
      mockSummariesApi.list.mockResolvedValue([]);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleCreateNewSummary();
      });

      expect(result.current.errorMessage).toBeNull();
    });
  });

  describe("polling behavior", () => {
    it("starts polling when summary is pending", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({ id: "1", status: "pending" })
      );
      const newSummary = createMockSummary({ id: "1", status: "pending" });
      mockSummariesApi.create.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.selectedSummaryId).toBe("1");
      });

      act(() => {
        jest.advanceTimersByTime(1500);
      });

      await waitFor(() => {
        expect(mockSummariesApi.getById).toHaveBeenCalled();
      });
    });

    it("stops polling when summary is completed", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({
          id: "1",
          status: "completed",
          summary: "Completed summary",
        })
      );
      const newSummary = createMockSummary({ id: "1", status: "pending" });
      mockSummariesApi.create.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.selectedSummaryId).toBe("1");
      });

      act(() => {
        jest.advanceTimersByTime(1500);
      });

      await waitFor(() => {
        expect(result.current.selectedSummary?.status).toBe("completed");
      });
    });

    it("sets error when summary fails", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      mockSummariesApi.getById.mockResolvedValue(
        createMockSummary({
          id: "1",
          status: "failed",
          summary: "Error message from server",
        })
      );
      const newSummary = createMockSummary({ id: "1", status: "pending" });
      mockSummariesApi.create.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.errorMessage).toBe("Error message from server");
      });
    });

    it("uses fallback error message when summary fails without message", async () => {
      mockSummariesApi.list.mockResolvedValue([]);
      const failedSummary = createMockSummary({
        id: "1",
        status: "failed",
        summary: "",
      });
      mockSummariesApi.getById.mockResolvedValue(failedSummary);
      const newSummary = createMockSummary({ id: "1", status: "pending" });
      mockSummariesApi.create.mockResolvedValue(newSummary);

      const { result } = renderHook(() => useHomeSummaries(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => {
        expect(result.current.isLoadingSummaries).toBe(false);
      });

      act(() => {
        result.current.handleSubmitText("Test text");
      });

      await waitFor(() => {
        expect(result.current.errorMessage).toBe(
          "Falha ao criar o resumo. Tente novamente."
        );
      });
    });
  });
});
