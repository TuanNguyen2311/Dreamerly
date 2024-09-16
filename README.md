# Dreamerly
1/ Mô tả thiết kế:
- Theo yêu cầu đưa ra, tôi đã thiết kế ứng dụng với 3 màn hình chính bao gồm TaskList và Biểu đồ.
- Ở màn hình TaskList cho phép người dùng theo dõi các Project theo ngày và trạng thái của Project. Người dùng có thể dễ dàng tạo mới 1 project mới khi click vào button Plus ở góc phải giao diện. Trường hợp muốn chỉnh sửa thì người dùng có thể chọn các item muốn chỉnh sửa. Khi muốn xoá project thì chỉ cần swipe item cần xoá từ phải sang trái thì sẽ hiển thị button để xoá item đó.
- Trong màn hình thêm và sửa project, ta có 2 phần chính là thông tin project, bao gồm: Tên project, độ ưu tiên project(Low,Medium,High,Urgent), ngày bắt đầu và ngày kết thúc của project đó. Phần thứ 2 là danh sách các task nhỏ thuộc Project. Các task có 2 thuộc tính là Tên và trạng thái(đỏ:chưa hoàn thành - Xanh: Đã hoàn thành).
- Trạng thái của 1 project sẽ phụ thuộc vào các yếu tố thời gian cũng như mức độ hoàn thành các task tương ứng. 1 project có toàn bộ task đã hoàn thành và hoàn thành trước deadline thì sẽ tính là hoàn thành. Còn nếu vượt quá sẽ là Cancel.
- Màn hình Biểu đồ thể hiện biểu đồ các Project theo trạng thái 
2/ Các cải tiến trong tương lai:
- Xử lý lưu dữ liệu cho app
- Xử lý đặt lịch thông báo
- Thêm các ràng buộc thời gian, ví dụ: thời gian bắt đầu phải nhỏ hơn hoặc bằng thời gian kết thúc
- Thêm các giới hạn thao tác, ví dụ: các project đã bị tính là Cancel thì không thể chỉnh sửa nội dung
- Thêm các hiệu ứng animation cho các button cũng như các view khi hiển thị và thao tác
- 
