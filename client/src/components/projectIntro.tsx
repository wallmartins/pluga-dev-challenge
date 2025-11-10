"use client";

import { Sparkles } from "lucide-react";

export function ProjectIntro() {
  return (
    <div className="flex flex-col gap-6 sm:gap-8 max-w-2xl mx-auto w-full">
      <div className="flex items-center justify-center gap-2">
        <Sparkles className="h-6 w-6 sm:h-8 sm:w-8 text-blue-600 dark:text-blue-400" />
        <h2 className="text-3xl sm:text-4xl font-bold text-zinc-900 dark:text-white">
          EssentIA
        </h2>
        <Sparkles className="h-6 w-6 sm:h-8 sm:w-8 text-blue-600 dark:text-blue-400" />
      </div>

      <div className="text-center px-2">
        <p className="text-base sm:text-lg text-zinc-600 dark:text-zinc-300">
          Extraia a essência do seu texto. EssentIA utiliza inteligência
          artificial para criar resumos precisos e concisos de qualquer conteúdo
          que você enviar.
        </p>
      </div>

      <div className="rounded-lg border border-zinc-200 bg-white p-4 sm:p-6 dark:border-zinc-800 dark:bg-zinc-950/50">
        <h3 className="mb-3 sm:mb-4 text-base sm:text-lg font-semibold text-zinc-900 dark:text-white">
          Como usar:
        </h3>
        <ul className="space-y-2 sm:space-y-3">
          <li className="flex gap-2 sm:gap-3">
            <span className="flex h-5 w-5 sm:h-6 sm:w-6 items-center justify-center rounded-full bg-blue-600 text-xs sm:text-sm font-medium text-white dark:bg-blue-500 shrink-0">
              1
            </span>
            <span className="text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
              Cole ou digite o texto que deseja resumir no campo abaixo
            </span>
          </li>
          <li className="flex gap-2 sm:gap-3">
            <span className="flex h-5 w-5 sm:h-6 sm:w-6 items-center justify-center rounded-full bg-blue-600 text-xs sm:text-sm font-medium text-white dark:bg-blue-500 shrink-0">
              2
            </span>
            <span className="text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
              Clique no botão &quot;Resumir&quot; para processar o seu texto
            </span>
          </li>
          <li className="flex gap-2 sm:gap-3">
            <span className="flex h-5 w-5 sm:h-6 sm:w-6 items-center justify-center rounded-full bg-blue-600 text-xs sm:text-sm font-medium text-white dark:bg-blue-500 shrink-0">
              3
            </span>
            <span className="text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
              Aguarde alguns segundos enquanto a IA analisa o conteúdo
            </span>
          </li>
          <li className="flex gap-2 sm:gap-3">
            <span className="flex h-5 w-5 sm:h-6 sm:w-6 items-center justify-center rounded-full bg-blue-600 text-xs sm:text-sm font-medium text-white dark:bg-blue-500 shrink-0">
              4
            </span>
            <span className="text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
              Visualize o resumo e compare com o texto original usando o botão
              toggle
            </span>
          </li>
        </ul>
      </div>

      <div className="rounded-lg border border-zinc-200 bg-white p-4 sm:p-6 dark:border-zinc-800 dark:bg-zinc-950/50">
        <h3 className="mb-3 sm:mb-4 text-base sm:text-lg font-semibold text-zinc-900 dark:text-white">
          Requisitos do texto:
        </h3>
        <ul className="space-y-2">
          <li className="flex gap-2 text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
            <span className="text-blue-600 dark:text-blue-400">•</span>
            Mínimo de 300 caracteres
          </li>
          <li className="flex gap-2 text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
            <span className="text-blue-600 dark:text-blue-400">•</span>
            Pode ser qualquer tipo de conteúdo (artigos, notícias, emails, etc.)
          </li>
          <li className="flex gap-2 text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
            <span className="text-blue-600 dark:text-blue-400">•</span>O botão
            ficará desabilitado enquanto o campo tiver vazio.
          </li>
          <li className="flex gap-2 text-sm sm:text-base text-zinc-700 dark:text-zinc-300">
            <span className="text-blue-600 dark:text-blue-400">•</span>
            Texto que sejam só caracteres especiais também não serão aceitos.
          </li>
        </ul>
      </div>
    </div>
  );
}
