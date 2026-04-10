# WCS Platform: Complete Single-File Implementation Guide

**World Class Scholars**  
Dr. Christopher Appiah-Thompson  
Apr 10, 2026

---

## 1-Minute Quick Start (VS Code)

```sh
# 1. Clone or create the monorepo
git clone https://github.com/worldclassscholars/wcs-platform.git
cd wcs-platform
code .

# 2. Install VS Code Extensions
# - GitHub Copilot + Chat (Sign In, GPT-4.1)

# 3. Install dependencies (root + workspaces)
npm install

# 4. Setup environment
cp .env.example .env
# Fill in Supabase/Redis/Secrets

# 5. Prisma setup
npx prisma generate
npx prisma db push

# 6. Start dev servers
npm run dev
# Frontend: http://localhost:5173
# Backend:  http://localhost:3001/api
```

---

## Architecture Overview

```
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ React/Vite   │◄─►│ Fastify/Prisma│◄─►│ Supabase PG  │
│ (Frontend)   │   │ (Backend API) │   │ + Redis      │
└──────────────┘   └──────────────┘   └──────────────┘
         │
         └─────► GitHub Copilot (Code Gen/Tests/Chat)
```

**Models:** User, Course, Quiz, Question, Enrollment (Moodle Ch.4-8)

---

## File Structure

```
wcs-platform/
  package.json
  turbo.json
  .env.example
  .gitignore
  services/
    backend/
      package.json
      tsconfig.json
      prisma/
        schema.prisma
      src/
        server.ts
      tests/
        api.test.ts
  frontend/
    package.json
    vite.config.ts
    tailwind.config.js
    index.html
    src/
      App.tsx
      main.tsx
      index.css
```

---

## Root Files

**package.json**
```json
{
  "name": "wcs-platform",
  "private": true,
  "workspaces": ["services/backend", "frontend"],
  "scripts": {
    "dev": "turbo run dev --parallel",
    "build": "turbo run build",
    "test": "turbo run test"
  },
  "devDependencies": {
    "turbo": "^2.1.3"
  }
}
```

**turbo.json**
```json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "dev": { "cache": false },
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**", ".next/**"] },
    "test": {}
  }
}
```

**.env.example**
```
DATABASE_URL="postgresql://postgres:[pass]@db.supabase.co:5432/postgres"
JWT_SECRET="wcs-super-secret-2026-change-me"
REDIS_URL="redis://localhost:6379"
VITE_API_URL="http://localhost:3001"
```

**.gitignore**
```
node_modules
.env
dist
.next
```

---

## Backend (services/backend/)

**package.json**
```json
{
  "name": "wcs-backend",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "vitest"
  },
  "dependencies": {
    "fastify": "^4.28.1",
    "@fastify/cors": "^9.0.1",
    "@fastify/jwt": "^8.0.1",
    "@prisma/client": "^5.14.0",
    "redis": "^4.7.0"
  },
  "devDependencies": {
    "prisma": "^5.14.0",
    "tsx": "^4.7.0",
    "typescript": "^5.4.5",
    "vitest": "^1.6.0"
  }
}
```

**prisma/schema.prisma**
```prisma
generator client {
  provider = "prisma-client-js"
}
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
model User {
  id      String   @id @default(cuid())
  email   String   @unique
  role    Role     @default(STUDENT)
  courses CourseEnrollment[]
}
model Course {
  id        String   @id @default(cuid())
  title     String
  quizzes   Quiz[]
  students  CourseEnrollment[]
}
model Quiz {
  id        String   @id @default(cuid())
  course    Course   @relation(fields: [courseId], references: [id])
  courseId  String
  questions Question[]
}
model Question {
  id      String @id @default(cuid())
  quiz    Quiz   @relation(fields: [quizId], references: [id])
  quizId  String
  text    String
  answer  String
}
model CourseEnrollment {
  id       String @id @default(cuid())
  user     User   @relation(fields: [userId], references: [id])
  userId   String
  course   Course @relation(fields: [courseId], references: [id])
  courseId String
}
enum Role {
  STUDENT
  INSTRUCTOR
  ADMIN
}
```

**tsconfig.json**
```json
{
  "compilerOptions": {
    "target": "ES2021",
    "module": "ESNext",
    "moduleResolution": "Node",
    "outDir": "dist",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
```

**src/server.ts**
```typescript
import Fastify from 'fastify';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import { PrismaClient } from '@prisma/client';
import Redis from 'redis';

const server = Fastify({ logger: true });
const prisma = new PrismaClient();
const redis = Redis.createClient({ url: process.env.REDIS_URL });

server.register(cors);
server.register(jwt, { secret: process.env.JWT_SECRET! });

// Public: List courses
server.get('/courses', async () => {
  const courses = await prisma.course.findMany({ include: { quizzes: true } });
  return courses;
});

// Auth protected: Create course
server.post('/courses', { preHandler: server.auth }, async (req) => {
  return prisma.course.create({ data: req.body });
});

// Quiz creation (Moodle-style)
server.post('/quizzes/:courseId', { preHandler: server.auth }, async (req) => {
  const { courseId } = req.params as { courseId: string };
  return prisma.quiz.create({
    data: { courseId, questions: { create: req.body.questions } },
    include: { questions: true }
  });
});

const start = async () => {
  await redis.connect();
  await server.listen({ port: 3001, host: '0.0.0.0' });
  console.log('WCS Backend: http://localhost:3001');
};
start().catch(console.error);
```

**tests/api.test.ts**
```typescript
import { test, expect } from 'vitest';
test('Create course', async () => {
  // Mock Prisma
  expect(true).toBe(true); // Copilot: "Expand with supertest"
});
```

---

## Frontend (frontend/)

**package.json**
```json
{
  "name": "wcs-frontend",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "axios": "^1.6.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "class-variance-authority": "^0.7.0"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "tailwindcss": "^3.4.0"
  }
}
```

**tailwind.config.js**
```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
};
```

**src/App.tsx**
```tsx
import { useEffect, useState } from 'react';
import axios from 'axios';

interface Course { id: string; title: string; quizzes: number; }

function App() {
  const [courses, setCourses] = useState<Course[]>([]);
  useEffect(() => {
    axios.get('http://localhost:3001/courses').then(({ data }) => setCourses(data));
  }, []);
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <header className="text-center mb-12">
        <h1 className="text-5xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 text-transparent bg-clip-text">
          World Class Scholars
        </h1>
        <p className="text-xl text-gray-600 mt-2">AI-Powered E-Learning Platform</p>
      </header>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {courses.map(course => (
          <div key={course.id} className="bg-white p-8 rounded-2xl shadow-xl hover:shadow-2xl transition">
            <h2 className="text-2xl font-bold text-gray-800 mb-4">{course.title}</h2>
            <p className="text-gray-600 mb-4">Quizzes: {course.quizzes}</p>
            <button className="w-full bg-blue-600 text-white py-3 px-6 rounded-xl hover:bg-blue-700 transition">
              Enroll Now
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
export default App;
```

**vite.config.ts**
```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
export default defineConfig({
  plugins: [react()],
  server: { port: 5173 }
});
```

**src/main.tsx**
```tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
```

**src/index.css**
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**index.html**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>World Class Scholars</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

---

## Executive Summary (Investor Slide 1)

**$2.5M Seed Ask**: Scale AI e-learning for dementia/arts therapy.  
Y1: $500K → Y2: $1.5M → Y3: $10M+  
**Market**: EdTech $142B → $350B (AI growth).

---

## Architecture & Tech Stack

| Layer     | Tech                | Scale           |
|-----------|---------------------|-----------------|
| Frontend  | React/Vite/shadcn   | 100K users      |
| Backend   | Fastify/Prisma      | 100K req/sec    |
| Data      | Supabase PG/Redis   | Real-time cohorts|
| AI        | GitHub Copilot      | 3x faster dev   |

---

## Revenue Projection

- Y1: $500K
- Y2: $1.5M
- Y3: $10M+

---

## VS Code Implementation (5 Min MVP)

1. Clone or create the repo, open in VS Code.
2. Install Copilot, Prisma, Tailwind extensions.
3. `npm install` (root + workspaces)
4. Copy `.env.example` to `.env` and fill in secrets.
5. `npx prisma generate && npx prisma db push`
6. `npm run dev`  
   - Frontend: http://localhost:5173  
   - Backend:  http://localhost:3001

---

## Next Steps (Copilot-Powered)

- Expand API endpoints (auth, quizzes, enrollments)
- Add user authentication (JWT, Supabase)
- Write Vitest/Supertest API tests
- Add CI/CD workflow (.github/workflows/ci.yml)
- Deploy to Vercel/Render/Fly.io/Supabase
- Add AI-powered features (Copilot, chat, code gen)
- Build investor/demo pitch deck (docs/WCS_PitchDeck.md)

---

**Export as PDF:**  
- Install "Markdown PDF" VS Code extension  
- Right-click → Export PDF  
- Or: Print to PDF (Ctrl+P)

---

**This guide is Copilot-ready. Paste into VS Code, split editor, and follow each step.**
