# 🦷 Dentist Game - iOS Native Application

Trò chơi bác sĩ nha khoa trẻ em dành cho nền tảng iOS (iPhone / iPad), phát triển 100% Native bằng **SwiftUI** và **SpriteKit**.

---

## 🚀 Tự Động Build File IPA (GitHub Actions)
Repository này đã được tích hợp sẵn GitHub Actions workflow:
* **Workflow:** `.github/workflows/build-ipa.yml`
* Tự động biên dịch mã nguồn trên máy chủ macOS của GitHub mỗi khi có code mới.
* Tự động đóng gói file **`DentistGame.ipa`**.
* File IPA sẵn sàng tải về tại tab **Actions** (Artifacts) hoặc mục **Releases**.

---

## 📱 Cài Đặt Vào iPhone Từ Máy Tính Windows
1. Tải file `DentistGame.ipa` từ tab **Releases** hoặc **Actions** về máy Windows.
2. Cắm iPhone vào máy tính Windows bằng cáp USB, mở khóa màn hình và chọn **Tin cậy**.
3. Mở phần mềm **Sideloadly** trên máy tính.
4. Kéo thả file `DentistGame.ipa` vào giao diện Sideloadly.
5. Nhập tài khoản **Apple ID** của bạn (miễn phí) và nhấn **START**.
6. Sau khi cài xong, trên iPhone vào:
   * **Cài đặt > Cài đặt chung > Quản lý VPN & Thiết bị** ➔ Chọn Apple ID của bạn ➔ Nhấn **Tin cậy**.
   * *(Nếu dùng iOS 16+)*: Bật thêm **Chế độ nhà phát triển (Developer Mode)** trong *Cài đặt > Quyền riêng tư & Bảo mật*.
