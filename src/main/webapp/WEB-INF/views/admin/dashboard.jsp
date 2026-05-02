<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <%@ include file="layout/head.jspf" %>
</head>
<body class="bg-surface text-on-surface">
<%@ include file="layout/sidebar.jspf" %>

<main class="ml-64 min-h-screen">
    <%@ include file="layout/topbar.jspf" %>

    <div class="p-8 space-y-8">
        <section class="primary-gradient text-white rounded-3xl p-10 relative overflow-hidden">
            <h1 class="text-4xl font-headline font-black mb-3">Chào buổi sáng, Admin</h1>
            <p class="max-w-2xl text-indigo-100">Welcome back to The Editorial Scholar. You have 12 new vocabulary contributions and 3 high-priority reports to review today.</p>
            <div class="mt-7 flex gap-4">
                <button class="px-6 py-2.5 rounded-2xl bg-white text-primary font-bold text-sm">Review Tasks</button>
                <button class="px-6 py-2.5 rounded-2xl glass-cta text-white font-bold text-sm">Generate Weekly Report</button>
            </div>
        </section>

        <section class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Total Users</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2">48,291</h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Active Today</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2">12,402</h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Lessons Done</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2">856,220</h3>
            </article>
            <article class="bg-surface-container-lowest rounded-2xl p-6">
                <p class="text-xs font-bold tracking-wider text-slate-500 uppercase">Revenue Gained</p>
                <h3 class="text-3xl text-primary font-black font-headline mt-2">$4,280</h3>
            </article>
        </section>

        <section class="grid grid-cols-1 xl:grid-cols-3 gap-8">
            <div class="xl:col-span-2 bg-surface-container-low rounded-3xl p-8">
                <h4 class="text-xl text-primary font-headline font-black">User Growth</h4>
                <p class="text-sm text-slate-500 mb-6">Registered students over the last 30 days</p>
                <div class="h-64 flex items-end gap-2">
                    <div class="flex-1 bg-primary/15 rounded-t-lg" style="height: 42%"></div>
                    <div class="flex-1 bg-primary/15 rounded-t-lg" style="height: 57%"></div>
                    <div class="flex-1 bg-primary/15 rounded-t-lg" style="height: 66%"></div>
                    <div class="flex-1 bg-primary/30 rounded-t-lg" style="height: 78%"></div>
                    <div class="flex-1 bg-primary/45 rounded-t-lg" style="height: 92%"></div>
                    <div class="flex-1 bg-primary/65 rounded-t-lg" style="height: 100%"></div>
                </div>
            </div>
            <div class="bg-surface-container-low rounded-3xl p-8">
                <h4 class="text-xl text-primary font-headline font-black">Topic Popularity</h4>
                <p class="text-sm text-slate-500 mb-6">Lesson engagement by category</p>
                <div class="w-44 h-44 rounded-full border-[22px] border-primary-container mx-auto relative">
                    <div class="absolute inset-0 rounded-full border-[22px] border-orange-300" style="clip-path: polygon(50% 50%, 50% 0, 100% 0, 100% 100%, 0 100%, 0 70%);"></div>
                    <div class="absolute inset-0 flex items-center justify-center font-black text-primary">82%</div>
                </div>
            </div>
        </section>
    </div>
    <%@ include file="layout/footer.jspf" %>
</main>
</body>
</html>
