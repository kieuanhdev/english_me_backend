<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <%@ include file="layout/head.jspf" %>
</head>
<body class="bg-surface font-body text-on-surface">
<header class="fixed top-0 left-0 right-0 z-50 bg-[#f9f9f9] shadow-[0_4px_24px_0_rgba(26,28,28,0.04)] backdrop-blur-[12px]">
    <nav class="flex justify-between items-center w-full px-6 py-4 max-w-7xl mx-auto">
        <div class="text-2xl font-bold text-[#24389c] tracking-tight font-headline">EnglishMe</div>
        <a class="text-slate-500 hover:bg-[#f3f3f4] transition-colors duration-300 px-4 py-2 rounded-xl text-sm font-medium" href="#">Support</a>
    </nav>
</header>

<main class="min-h-screen flex items-center justify-center pt-20 pb-12 px-4 sm:px-6 lg:px-8">
    <div class="w-full max-w-6xl grid grid-cols-1 lg:grid-cols-12 gap-0 overflow-hidden rounded-[2rem] bg-surface-container-low shadow-2xl">
        <div class="relative hidden lg:block lg:col-span-7 overflow-hidden">
            <img alt="Institutional Library" class="absolute inset-0 w-full h-full object-cover"
                 src="https://lh3.googleusercontent.com/aida-public/AB6AXuDiU1vHX_iIO0X_gQBTCdKpAr3LdVP_76VpTmT_2idZfVLfnO97sr-Lyy4mRSTcvgs2S4EkQlOLlCKmkGCKKfOQmjf2-U6TVaBO2T_l8gPc7njjHgcf_fcQ5eTEABajMvL2PqpnIlJz3VFNnsFtEfykW8cUAS6ShJqyP7ugppMp2s7MF98ErFrn53_gjPHw8HkrlHi7cLp6GMmnPhnlv4Np65qLDckBfltINAgZG0sDc_ed2Hok7j2RquE1R1_hpxno-FUJM_FEa1w"/>
            <div class="absolute inset-0 bg-gradient-to-br from-primary/60 to-primary-container/40 flex flex-col justify-end p-16">
                <div class="max-w-md">
                    <h2 class="font-headline text-4xl font-extrabold text-white leading-tight mb-4">
                        Kien thuc la nen tang cua thanh cong.
                    </h2>
                    <p class="text-white/90 text-lg font-medium">
                        Quan ly hanh trinh hoc tap hien dai voi he thong quan tri EnglishMe chuyen nghiep va tinh te.
                    </p>
                </div>
            </div>
        </div>

        <div class="lg:col-span-5 bg-surface-container-lowest p-8 md:p-12 lg:p-16 flex flex-col justify-center">
            <div class="w-full max-w-sm mx-auto">
                <div class="mb-10">
                    <h1 class="font-headline text-2xl md:text-3xl font-extrabold text-primary mb-2 tracking-tight">
                        He thong quan tri EnglishMe
                    </h1>
                    <p class="text-on-surface-variant font-medium text-base">
                        Vui long dang nhap voi quyen ADMIN de tiep tuc
                    </p>
                </div>

                <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
                <% if (errorMessage != null) { %>
                <div class="mb-4 rounded-xl bg-red-50 px-4 py-3 text-sm font-semibold text-red-700">
                    <%= errorMessage %>
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/admin/login" method="post" class="space-y-6">
                    <div class="space-y-4">
                        <div>
                            <label class="block text-sm font-semibold text-on-surface mb-2 ml-1" for="email">Email</label>
                            <div class="relative">
                                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline-variant">mail</span>
                                <input class="w-full pl-12 pr-4 py-4 bg-surface-container-high border-none rounded-xl text-on-surface placeholder:text-outline focus:ring-2 focus:ring-primary/20 focus:bg-surface-container-lowest transition-all duration-300 outline-none"
                                       id="email" name="email" placeholder="admin@englishme.vn" type="email" required/>
                            </div>
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-on-surface mb-2 ml-1" for="password">Mat khau</label>
                            <div class="relative">
                                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline-variant">lock</span>
                                <input class="w-full pl-12 pr-4 py-4 bg-surface-container-high border-none rounded-xl text-on-surface placeholder:text-outline focus:ring-2 focus:ring-primary/20 focus:bg-surface-container-lowest transition-all duration-300 outline-none"
                                       id="password" name="password" placeholder="••••••••" type="password" required/>
                            </div>
                        </div>
                    </div>

                    <button class="w-full py-4 bg-gradient-to-r from-[#24389c] to-[#3f51b5] text-white font-bold rounded-xl text-lg hover:shadow-lg hover:scale-[1.01] active:scale-[0.99] transition-all duration-300 flex items-center justify-center gap-2"
                            type="submit">
                        Dang nhap
                        <span class="material-symbols-outlined">arrow_forward</span>
                    </button>
                </form>
            </div>
        </div>
    </div>
</main>
</body>
</html>
