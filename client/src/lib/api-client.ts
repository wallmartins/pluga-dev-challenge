import axios from "axios";
import type { CreateSnippetPayload, SnippetResponse, SnippetsListResponse } from "./types";

export const createApiClient = () => {
  const apiBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3000";
  return axios.create({
    baseURL: apiBaseUrl,
    headers: {
      "Content-Type": "application/json",
    },
  });
};

const api = createApiClient();

export const createSummariesApi = (apiClient = api) => ({
  create: async (payload: CreateSnippetPayload): Promise<SnippetResponse> => {
    const { data } = await apiClient.post<SnippetResponse>("/summaries", payload);
    return data;
  },

  getById: async (id: string): Promise<SnippetResponse> => {
    const { data } = await apiClient.get<SnippetResponse>(`/summaries/${id}`);
    return data;
  },

  list: async (): Promise<SnippetsListResponse> => {
    const { data } = await apiClient.get<SnippetsListResponse>("/summaries");
    return data;
  },
});

export const summariesApi = createSummariesApi();
