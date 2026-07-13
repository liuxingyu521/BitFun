import React from 'react';
import ReactMarkdown from 'react-markdown';
import type { Components } from 'react-markdown';
import remarkGfm from 'remark-gfm';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import type { PluggableList } from 'unified';
import type { Pluggable } from 'unified';
import 'katex/dist/katex.min.css';

interface MarkdownMathRendererProps {
  markdownContent: string;
  components: Components;
  rehypePlugins: PluggableList;
  remarkAutolinkComputerFileLinks: Pluggable;
}

export const MarkdownMathRenderer: React.FC<MarkdownMathRendererProps> = ({
  markdownContent,
  components,
  rehypePlugins,
  remarkAutolinkComputerFileLinks,
}) => (
  <ReactMarkdown
    remarkPlugins={[remarkGfm, remarkMath, remarkAutolinkComputerFileLinks]}
    rehypePlugins={[...rehypePlugins, rehypeKatex]}
    components={components}
  >
    {markdownContent}
  </ReactMarkdown>
);

export default MarkdownMathRenderer;
