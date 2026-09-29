---
id: annot-text
name: @Text
category: annotations
kind: annotation
tokens: @Text @Multiline
sig: @Text name: Key = null  /  @Text @Multiline blurb: string = ""
tip: Read by the player, so translated; and prose, edited over several lines.
order: 72
---

<code>@Text</code> marks what the player reads, so it is translated. On a <code>Key</code> field a row that gives no value gets its derived key, <code>&lt;registry&gt;.&lt;row&gt;.&lt;field&gt;</code> (see <code>@TextKey</code>); English still written in a <code>@Text</code> row is counted as <code>english_left</code>. <code>@Multiline</code> says it is prose, edited as several lines rather than one.
