const links = `
https://github.com/dustinblackman/gomodrun/releases/download/v0.4.5/gomodrun_0.4.5_linux_arm64.deb
https://github.com/dustinblackman/gomodrun/releases/download/v0.4.5/gomodrun_0.4.5_linux_amd64.deb
https://github.com/dustinblackman/cf-alias/releases/download/v0.1.9/cf-alias_0.1.9_linux_amd64.deb
https://github.com/dustinblackman/languagetool-code-comments/releases/download/v0.4.4/languagetool-code-comments_0.4.4_linux_amd64.deb
https://github.com/dustinblackman/languagetool-code-comments/releases/download/v0.4.4/languagetool-code-comments_0.4.4_linux_arm64.deb
`;

export function onRequest(context) {
  const link = links.split('\n').filter(e => e).find(e => e.includes(context.params.file));
  if (!link) {
    return new Response(`${context.params.file} not found.`, { status: '404' });
  }

  return Response.redirect(context.params.file, 302);
}
