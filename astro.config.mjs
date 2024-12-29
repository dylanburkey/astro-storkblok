// astro.config.mjs
import { defineConfig } from 'astro/config';
import storyblok from '@storyblok/astro';
//

export default defineConfig({
  integrations: [
    storyblok({
      accessToken: process.env.PUBLIC_STORYBLOK_TOKEN,
      apiOptions: {
        region: 'us',
      },
      components: {
        page: 'storyblok/Page',
        blogPost: 'storyblok/BlogPost',
        blogOverview: 'storyblok/BlogOverview',
        feature: 'storyblok/Feature',
        grid: 'storyblok/Grid',
        teaser: 'storyblok/Teaser',
        hero: 'storyblok/Hero',
      },
    })
  ],
});

