# MD Save

MD Save is a tiny macOS app for quickly saving Markdown notes into an Obsidian vault.

It solves a simple problem: you have a long piece of Markdown text and want to save it into your vault without opening Terminal, creating a file manually, or thinking about filenames.

## What It Does

- Lets you choose your own Obsidian vault folder.
- Provides a simple window with:
  - a file topic field
  - a large Markdown text area
  - a Paste Clipboard button
  - a Save button
  - Command+S support
- Saves notes as:

```text
YYMMDD_topic.md
```

Example:

```text
260607_product_strategy.md
```

If the filename already exists, MD Save creates a unique name such as:

```text
260607_product_strategy_2.md
```

## Input and Output

Input:

- Your chosen Obsidian vault folder
- A short file topic
- Markdown text typed or pasted into the app

Output:

- One local `.md` file inside the selected vault folder

MD Save does not upload, sync, analyze, or send your note content anywhere.

## Privacy

MD Save is local-only.

- No network calls
- No telemetry
- No AI API calls
- No bundled personal vault path
- No access to your notes except the folder you choose

The selected vault path is stored locally in macOS `UserDefaults` for the app, so you do not have to choose it every time.

## Requirements

- macOS 13 or later
- Xcode Command Line Tools for building from source

## Build

```bash
./scripts/build.sh
```

The built app will be created at:

```text
build/MD Save.app
```

The build script:

- compiles the Swift/AppKit source
- generates a macOS `.icns` from `assets/AppIcon.png`
- ad-hoc signs the app for local use

## Test Without Touching Your Vault

Use a temporary folder:

```bash
tmpdir="$(mktemp -d)"
MDSAVE_VAULT="$tmpdir" "build/MD Save.app/Contents/MacOS/MDSave" --self-test
find "$tmpdir" -type f -maxdepth 1 -print
```

## Install

After building, move the app wherever you like, for example:

```bash
cp -R "build/MD Save.app" ~/Applications/
```

On first launch, choose your Obsidian vault folder.

## License

MIT

---

## About Uglytude

I'm SpaceMiao. You can call me MiaoMiao. Uglytude is a brand I made up.

I'm a drawing hobbyist, not a programmer. Apart from a required C course at university, I had never written a single app in my life. My philosophy is simple: if you want to make something, make an ugly one first. Ugly is better than nothing.

Uglytude didn't start as a brand. It started as an idea.

I crash all the time when I draw on livestream. The eyes go wrong, the face shape is off, the colors come out as something I never wanted. You can't talk yourself into "keep going, the next one will be pretty," because the next one probably won't be. So swap the goal: make ugly ones. When ugly is the goal, ugly becomes normal. You make ninety-nine failures normal, and that's how you reach the hundredth.

I gave the idea a name. In Chinese, 耐丑力, the ability to endure the ugly. Then I went looking for an English word and ended up inventing one. Uglytude. An attitude towards your own drawings.

First it became a video, where people sketched along with me, drawing whatever they saw, not thinking about the result.

Then it became an app.

I had never made an app before, and never put anything on the App Store. I started vibe coding in January 2026, and the app shipped on 26 February. The first version did almost nothing: it hands you a random reference, you just draw, you don't decide anything else. Make one ugly drawing, that's the goal. Now it can hand you a random color palette too.

It's on build 14 now. But I have never changed a single thing about the UI. It's still ugly. Everything I ship is performance and features. It works, that's enough. It was an ugly thing on day one and it still is.

👉 [Uglytude](https://apps.apple.com/us/app/uglytude/id6759151455)

Then it became a shop. In Zurich, fourteen square meters, a stationery shop where you can draw.

I used to keep Uglytude for drawing only. Then it wandered off somewhere else.

Building the website for that shop, I realised I was using the same thing. I had never used GitHub, never built a website. I'm a perfectionist. An app had to be perfect before launching, a drawing had to be perfect before anyone could see it.

Then I found out that if you set the goal to "make an ugly thing", an ugly skill, an ugly extension, and share it publicly, you can actually start.

These are all tools I use every day. They're ugly and plainly packaged, but each one is a starting point, so the next build never starts from zero.

I share my ugly tools on GitHub. Most of them exist because I ran into the problem myself, at work, in life, or while learning to use AI. I needed it, so I made one. Once it worked, I put it out there.

- [highlight2comment](https://github.com/Uglytude/highlight2comment) — there are plenty of highlighters for the web already. I found all of them fussy. Mine does two things: keep the sentence, add a comment. Then it stops. Nothing else.
- [photo2md](https://github.com/Uglytude/photo2md) — whatever is inside a screenshot on your phone is stuck there. This gets it out.
- [md-save-app](https://github.com/Uglytude/md-save-app) — no picking a folder, no feeding it to an AI first. One click and the note is in your Obsidian vault.
- [pain2product](https://github.com/Uglytude/pain2product) — I have a lot of pain points. Collect them, and a pain point turns into a project. Then I share the project.
- [delegate-to-chatgpt-pro](https://github.com/Uglytude/delegate-to-chatgpt-pro) — I never knew whether to trust what the AI told me. This checks the answer against your own sources.
- [spacemiao-lesezimmer](https://github.com/Uglytude/spacemiao-lesezimmer) — I'm learning German. Tap a word in a picture book and the translation shows up.

They all live here 👉 [github.com/Uglytude](https://github.com/Uglytude)

The one you just downloaded is only one of them. One of the others might happen to solve something else for you.

So Uglytude isn't just the name of that app. It's my philosophy for making things. Making a drawing, making an app, opening a shop, writing a small tool. Same thing to me.

Making an ugly thing is OK. Ugly is better than nothing.

It's exactly because someone this bad at it could still pull it off that you get to think: maybe I could try too.

---

## 关于 Uglytude

我叫 SpaceMiao，你可以叫我妙妙。Uglytude 是我创造的一个品牌。

我是一个画画爱好者，不是程序员。除了大学必修 C 语言，我从来没有自己编过任何 APP。我的 philosophy 很简单：你要做一个东西，就先把一个丑的东西做出来。丑比没有好。

一开始 Uglytude 不是一个品牌，它就是我的一个想法。

我直播画画经常翻车。眼睛画坏了，脸型不对，颜色涂出来根本不是我要的。你很难说服自己「再坚持一下，下一幅就好看了」，因为下一幅多半还是不好看。那干脆把目标换掉：就画丑画。丑变成目标，丑就成了正常的事。你把九十九次失败变成正常，才画得到第一百张。

我给这个想法起了个名字，叫耐丑力，忍耐丑的能力。后来想找一个对应的英文，就造了一个词：Uglytude。一种面对自己的画的态度。

它先变成了一期视频，带大家画人物速写，看到什么画什么，不想结果。

后来变成了一个 App。

我以前从来没有做过 App，也没有在苹果商店上发过任何东西。2026 年 1 月我开始学 Vibe Coding，2 月 26 号 App 就上线了。第一版功能特别简单，随机给你一张参考图，你只管画，别的都不用管。画一张丑画，这就是目标。现在它也能随机出色卡了。

到现在是 build 14。但是它的 UI 到今天一个字都没改过，还是很丑。我改的都是性能和功能，能用就行。它从一开始就是一个丑东西，现在还是。

👉 [Uglytude（耐丑力）](https://apps.apple.com/us/app/uglytude/id6759151455)

再后来它变成一家店。在苏黎世，十四平方米，一家可以画画的文具店。

本来我是把 Uglytude 用在学画画上面的。后来用着用着，它就跑到别的地方去了。

我给这家店做网站的时候发现，我在用同一个东西。我以前从来没用过 GitHub，没建过网站。我是一个很完美主义的人，觉得 App 要完美才能放上去，画要完美才能放出来。

后来我发现，把目标定成「我做一个丑东西」，做一个丑的 skill，一个丑的插件，然后公开分享出去，这件事就能开始了。

这些都是我自己每天在用的工具。它丑，包装也不好看，但它是一个起点，让你下次再 build 什么东西，不是从零开始。

我在 GitHub 上分享我做的丑工具。大部分都是为了解决我自己在工作、生活、学 AI 的过程中真实碰到的问题。我需要，我就做一个；能用了，就公开分享。

- [highlight2comment](https://github.com/Uglytude/highlight2comment)：网页上的划线工具已经很多了，但我觉得都太花里胡哨。我这个只做两件事，把句子存下来，写一句评论，然后就结束了，不做别的。
- [photo2md](https://github.com/Uglytude/photo2md)：手机截图里的内容存不下来，这个把它弄出来。
- [md-save-app](https://github.com/Uglytude/md-save-app)：不用挑文件夹，也不用先喂给 AI，一键就进你的 Obsidian vault。
- [pain2product](https://github.com/Uglytude/pain2product)：我有很多痛点。把痛点收集起来，它就变成一个项目，然后我把这个项目分享出去。
- [delegate-to-chatgpt-pro](https://github.com/Uglytude/delegate-to-chatgpt-pro)：AI 给的答案我一直不知道能不能信，这个会拿你自己的原始资料再核一遍。
- [spacemiao-lesezimmer](https://github.com/Uglytude/spacemiao-lesezimmer)：我在学德语，绘本点一下就出翻译。

全部在这里 👉 [github.com/Uglytude](https://github.com/Uglytude)

你现在下载的这个只是其中一个。剩下几个可能正好解决你别的问题。

所以 Uglytude 不只是那个 App 的名字，是我做东西的 philosophy。画一幅画、做一个 App、开一家店、写一个小工具，对我来说是同一件事。

做个丑东西，it's OK。丑比没有好。

正是因为我这么烂都能做成，你才会有信心说：「好像我也可以试一下。」
