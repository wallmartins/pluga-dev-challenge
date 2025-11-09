export type Snippet = {
  id: string;
  text: string;
  summary: string;
  original_post: string;
  status: "pending" | "completed" | "failed";
  createdAt?: string;
  updatedAt?: string;
};

export type CreateSnippetPayload = {
  summary: {
    original_post: string;
  };
};

export type SnippetResponse = Snippet;

export type SnippetsListResponse = Snippet[];
