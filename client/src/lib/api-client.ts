import axios from "axios";
import type { CreateSnippetPayload, SnippetResponse, SnippetsListResponse } from "./types";

const apiBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3000";

const api = axios.create({
  baseURL: apiBaseUrl,
  headers: {
    "Content-Type": "application/json",
  },
});

export const summariesApi = {
  create: async (payload: CreateSnippetPayload): Promise<SnippetResponse> => {
    const { data } = await api.post<SnippetResponse>("/summaries", payload);
    return data;
  },

  getById: async (id: string): Promise<SnippetResponse> => {
    const { data } = await api.get<SnippetResponse>(`/summaries/${id}`);
    return data;
  },

  list: async (): Promise<SnippetsListResponse> => {
    const { data } = await api.get<SnippetsListResponse>("/summaries");
    return data;
  },
};
