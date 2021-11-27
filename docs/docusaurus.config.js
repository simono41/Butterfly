/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: 'Linwood Butterfly',
  tagline: 'Next future, advanced, serverless, free note app',
  url: 'https://docs.butterfly.linwood.dev',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/favicon.ico',
  organizationName: 'LinwoodCloud', // Usually your GitHub org/user name.
  projectName: 'butterfly', // Usually your repo name.
  themeConfig: {
    navbar: {
      title: 'Linwood Butterfly',
      logo: {
        alt: 'Linwood Butterfly Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'doc',
          docId: 'intro',
          position: 'left',
          label: 'Tutorial',
        },
        {
          to: 'downloads',
          label: 'Downloads',
          position: 'left'
        },
        {
          to: 'community',
          position: 'left',
          label: 'Community',
        },
        {href: 'https://linwood.dev/blog', label: 'Blog', position: 'left'},
        {
          type: 'docsVersionDropdown',
          position: 'right',
          dropdownItemsBefore: [],
          dropdownItemsAfter: [{to: '/versions', label: 'All versions'}],
          dropdownActiveClassDisabled: true
        },
        {
          href: 'https://github.com/LinwoodCloud/Butterfly',
          label: 'GitHub',
          position: 'right',
        }
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Community',
          items: [
            {
              label: 'Discord',
              href: 'https://discord.linwood.dev',
            },
            {
              label: 'Twitter',
              href: 'https://twitter.com/LinwoodCloud',
            },
            {
              label: 'Contribution guide',
              href: 'https://github.com/LinwoodCloud/butterfly/blob/develop/CONTRIBUTING.md',
            },
            {
              html: `
                <a href="https://vercel.com?utm_source=Linwood&utm_campaign=oss" target="_blank" rel="noreferrer noopener" aria-label="Deploys by Netlify">
                  <img src="/img/powered-by-vercel.svg" alt="Deploys by Netlify" />
                </a>
              `,
            },
          ],
        },
        {
          title: 'Source code',
          items: [
            {
              label: 'App',
              href: 'https://github.com/LinwoodCloud/butterfly/tree/develop/app',
            },
            {
              label: 'Docs',
              href: 'https://github.com/LinwoodCloud/butterfly/tree/develop/docs',
            }
          ],
        },
        {
          title: 'Legal',
          items: [
            {
              label: 'Imprint',
              href: 'https://codedoctor.tk/impress',
            },
            {
              label: 'Privacy Policy',
              href: '/privacypolicy',
            },
          ],
        }
      ],
      logo: {
        alt: 'Linwood Logo',
        src: 'https://raw.githubusercontent.com/LinwoodCloud/website/main/public/Linwood.png',
        width: 100,
        href: 'https://linwood.dev',
      },
      copyright: `Copyright © ${new Date().getFullYear()} LinwoodCloud.`,
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl:
            'https://github.com/LinwoodCloud/butterfly/edit/develop/docs/',
        },
        blog: false,
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
  plugins: [
    [
      '@docusaurus/plugin-client-redirects',
      {
        redirects: [
          {
            to: '/privacypolicy', // string
            from: ['/docs/privacypolicy'], // string | string[]
          },
        ],
      },
    ],
    [
        '@docusaurus/plugin-content-docs',
        {
            id: 'community',
            path: 'community',
            routeBasePath: '/',
            sidebarPath: require.resolve('./sidebarsCommunity.js'),

        },
    ],
  ]
};
