export type Summary = {
  id: string;
  text: string;
  summary: string;
  original_post: string;
  status: "pending" | "completed" | "failed";
  createdAt?: string;
  updatedAt?: string;
};

export type CreateSummaryPayload = {
  summary: {
    original_post: string;
  };
};

export type SummaryResponse = Summary;

export type SummarysListResponse = Summary[];
