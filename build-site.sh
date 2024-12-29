#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to create directory if it doesn't exist
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${GREEN}Created directory:${NC} $1"
    else
        echo -e "${YELLOW}Directory already exists:${NC} $1"
    fi
}

# Function to create file if it doesn't exist
create_file() {
    if [ ! -f "$1" ]; then
        echo -e "$2" > "$1"
        echo -e "${GREEN}Created file:${NC} $1"
    else
        echo -e "${YELLOW}File already exists:${NC} $1"
    fi
}

echo "Checking project structure..."

# Check main directories
directories=(
    "src/components"
    "src/components/blog"
    "src/components/forms"
    "src/components/navigation"
    "src/components/typography"
    "src/components/ui"
    "src/layouts"
    "src/lib"
    "src/styles"
    "src/utils"
    "src/pages/about"
    "src/pages/services"
    "src/pages/blog"
    "src/pages/portfolio"
    "src/pages/account"
    "src/pages/contacts"
    "public/assets/img"
    "public/assets/css"
    "public/assets/js"
    "public/assets/vendor"
    "public/fonts"
    "src/content"
)

for dir in "${directories[@]}"; do
    create_dir "$dir"
done

# Create base page files if they don't exist
base_page_content='---
import BaseLayout from "../layouts/BaseLayout.astro";
---
<BaseLayout title="TITLE">
  <!-- Content here -->
</BaseLayout>'

# Create individual page files if they don't exist
declare -A pages
pages=(
    ["src/pages/index.astro"]="$base_page_content"
    ["src/pages/about/index.astro"]="${base_page_content/TITLE/About}"
    ["src/pages/about/v1.astro"]="${base_page_content/TITLE/About v1}"
    ["src/pages/about/v2.astro"]="${base_page_content/TITLE/About v2}"
    ["src/pages/services/index.astro"]="${base_page_content/TITLE/Services}"
    ["src/pages/services/v1.astro"]="${base_page_content/TITLE/Services v1}"
    ["src/pages/services/v2.astro"]="${base_page_content/TITLE/Services v2}"
    ["src/pages/services/single-v1.astro"]="${base_page_content/TITLE/Service Details}"
    ["src/pages/services/single-v2.astro"]="${base_page_content/TITLE/Service Details v2}"
)

for page in "${!pages[@]}"; do
    create_file "$page" "${pages[$page]}"
done

# Create blog-specific pages
blog_layout_content='---
import BlogLayout from "../../layouts/BlogLayout.astro";
---
<BlogLayout title="TITLE">
  <!-- Content here -->
</BlogLayout>'

blog_pages=(
    ["src/pages/blog/index.astro"]="Blog"
    ["src/pages/blog/list-with-sidebar.astro"]="Blog List"
    ["src/pages/blog/grid-with-sidebar.astro"]="Blog Grid"
    ["src/pages/blog/list-no-sidebar.astro"]="Blog List No Sidebar"
    ["src/pages/blog/grid-no-sidebar.astro"]="Blog Grid No Sidebar"
    ["src/pages/blog/simple-feed.astro"]="Blog Feed"
    ["src/pages/blog/podcast.astro"]="Blog Podcast"
)

for page in "${!blog_pages[@]}"; do
    content="${blog_layout_content/TITLE/${blog_pages[$page]}}"
    create_file "$page" "$content"
done

# Create dynamic blog post route if it doesn't exist
dynamic_blog_content='---
import BlogLayout from "../../layouts/BlogLayout.astro";
import { getCollection } from "astro:content";

export async function getStaticPaths() {
  const posts = await getCollection("blog");
  return posts.map(post => ({
    params: { slug: post.slug },
    props: { post }
  }));
}

const { post } = Astro.props;
---
<BlogLayout title={post.data.title}>
  <!-- Blog post content -->
</BlogLayout>'

create_file "src/pages/blog/[slug].astro" "$dynamic_blog_content"

# Check and create configuration files
create_file "astro.config.mjs" 'import { defineConfig } from "astro/config";
import storyblok from "@storyblok/astro";

export default defineConfig({
  integrations: [
    storyblok({
      accessToken: process.env.STORYBLOK_TOKEN,
      components: {
        // Add your Storyblok components here
      },
    }),
  ],
});'

# Create environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    echo "STORYBLOK_TOKEN=your_token_here
PUBLIC_STORYBLOK_TOKEN=your_public_token_here" > .env
    echo -e "${GREEN}Created .env file${NC}"
else
    echo -e "${YELLOW}.env file already exists${NC}"
fi

# Create content collection config if it doesn't exist
content_config='import { defineCollection, z } from "astro:content";

const blog = defineCollection({
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.date(),
    author: z.string(),
    image: z.object({
      url: z.string(),
      alt: z.string()
    }),
    category: z.string(),
    tags: z.array(z.string())
  })
});

export const collections = {
  blog
};'

create_file "src/content/config.ts" "$content_config"

# Create package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    echo "Checking for required dependencies..."
    npm init -y > /dev/null
    npm install @storyblok/astro sass @astrojs/tailwind --save-dev
    echo -e "${GREEN}Installed required dependencies${NC}"
else
    echo -e "${YELLOW}package.json already exists${NC}"
fi

echo -e "\n${GREEN}Project structure check complete!${NC}"
echo "Note: Existing files were not modified. Please review and update them manually if needed."
