<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Chính sách quyền riêng tư — EnglishMe</title>
    <style>
        :root {
            --primary: #2F6BFF;
            --text: #1F2430;
            --muted: #6B7280;
            --surface: #F7F8FC;
            --border: #E5E8F0;
        }
        * { box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
            margin: 0;
            background: var(--surface);
            color: var(--text);
            line-height: 1.65;
        }
        .header { background: var(--primary); color: #fff; padding: 32px 24px; }
        .header .wrap { max-width: 760px; margin: 0 auto; }
        .header h1 { margin: 0 0 6px; font-size: 26px; }
        .header p { margin: 0; opacity: 0.9; font-size: 14px; }
        .container {
            max-width: 760px;
            margin: -20px auto 48px;
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 32px 28px;
            box-shadow: 0 8px 24px rgba(31, 36, 48, 0.06);
        }
        h2 { font-size: 18px; margin: 28px 0 10px; color: var(--primary); }
        h2:first-of-type { margin-top: 0; }
        p, li { font-size: 15px; }
        ul { padding-left: 20px; }
        .updated { color: var(--muted); font-size: 13px; margin-bottom: 24px; }
        .footer {
            max-width: 760px; margin: 0 auto; text-align: center;
            color: var(--muted); font-size: 13px; padding: 0 24px 32px;
        }
        a { color: var(--primary); }
    </style>
</head>
<body>
<div class="header">
    <div class="wrap">
        <h1>Chính sách quyền riêng tư</h1>
        <p>EnglishMe — Ứng dụng học tiếng Anh</p>
    </div>
</div>

<div class="container">
    <p class="updated">Cập nhật lần cuối: 01/06/2026</p>

    <h2>1. Dữ liệu chúng tôi thu thập</h2>
    <ul>
        <li><strong>Thông tin tài khoản:</strong> họ tên, email (qua đăng ký hoặc Google).</li>
        <li><strong>Dữ liệu học tập:</strong> tiến độ, điểm XP, lịch sử ôn từ vựng, kết quả bài tập.</li>
        <li><strong>Bản ghi âm:</strong> đoạn ghi âm phát âm dùng để chấm điểm phát âm.</li>
        <li><strong>Dữ liệu kỹ thuật:</strong> loại thiết bị, nhật ký sự cố để cải thiện dịch vụ.</li>
    </ul>

    <h2>2. Mục đích sử dụng</h2>
    <ul>
        <li>Cung cấp và cá nhân hóa trải nghiệm học tập (lộ trình thích ứng).</li>
        <li>Chấm điểm phát âm bằng thuật toán so khớp.</li>
        <li>Theo dõi tiến độ, chuỗi ngày học và hệ thống điểm thưởng.</li>
        <li>Khắc phục sự cố và nâng cao chất lượng ứng dụng.</li>
    </ul>

    <h2>3. Chia sẻ dữ liệu</h2>
    <p>
        Chúng tôi không bán dữ liệu cá nhân. Dữ liệu chỉ được chia sẻ với nhà cung cấp hạ tầng
        cần thiết (xác thực, lưu trữ) theo nguyên tắc tối thiểu và bảo mật.
    </p>

    <h2>4. Lưu trữ và bảo mật</h2>
    <p>
        Dữ liệu được lưu trên máy chủ có biện pháp bảo vệ hợp lý. Mật khẩu được xác thực qua
        Firebase Authentication và không lưu dưới dạng văn bản thuần.
    </p>

    <h2>5. Quyền của bạn</h2>
    <ul>
        <li>Truy cập và chỉnh sửa thông tin cá nhân trong ứng dụng.</li>
        <li>Yêu cầu xóa tài khoản và dữ liệu liên quan.</li>
        <li>Rút lại sự đồng ý xử lý dữ liệu bất cứ lúc nào.</li>
    </ul>

    <h2>6. Liên hệ</h2>
    <p>
        Yêu cầu về quyền riêng tư xin gửi về:
        <a href="mailto:support@englishme.vn">support@englishme.vn</a>
    </p>

    <p style="margin-top:24px"><a href="/terms">← Quay lại Điều khoản sử dụng</a></p>
</div>

<div class="footer">
    © 2026 EnglishMe — Đồ án tốt nghiệp. Mọi quyền được bảo lưu.
</div>
</body>
</html>
