# Tài liệu API Đồng bộ (Sync API)

Tài liệu này hướng dẫn cách gọi API đồng bộ dữ liệu giữa Frontend (Mobile/Flutter) và Backend.

## 1. Thông tin chung
- **Endpoint**: `/api/sync`
- **Method**: `POST`
- **Content-Type**: `multipart/form-data`

## 2. Cấu trúc FormData
Dữ liệu được gửi lên dưới dạng **FormData** để hỗ trợ cả văn bản (JSON) và tệp tin (hình ảnh).

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `data` | `string` (JSON String) | **Yes** | Chứa toàn bộ thông tin đồng bộ (Users, Accounts, v.v.) |
| `avatar` | `file` | No | Các tệp tin hình ảnh đính kèm (nếu có) |

## 3. Cấu trúc JSON bên trong field `data`

Dữ liệu JSON gửi vào field `data` phải tuân thủ cấu trúc sau:

```json
{
  "uid": "IiKOog1ZqMRYGkruEo8bOxXgVO52",
  "users": [
    {
      "uid": "IiKOog1ZqMRYGkruEo8bOxXgVO52",
      "name": "Nguyen Van A",
      "email": "user@example.com",
      "picture": "url_hoac_path_anh",
      "dateOfBirth": "2000-01-01T00:00:00Z",
      "createdAt": "2025-01-01T10:00:00Z",
      "updatedAt": "2025-01-15T10:00:00Z",
      "isDeleted": false
    }
  ],
  "accounts": [
    {
      "id": "64b1f...", 
      "accountName": "Vietcombank",
      "balance": 5000000,
      "type": "bank",
      "currency": "vnd",
      "updatedAt": "2025-01-15T10:00:00Z",
      "isDeleted": false
    }
  ],
  "transactions": [
    {
      "uid": "IiKOog1ZqMRYGkruEo8bOxXgVO52",
      "accountId": "68c63b4b7f324939d8f5feba",
      "categoriesId": "exp_food",
      "amount": 50000,
      "transactionDate": "2025-01-15T12:00:00Z",
      "updatedAt": "2025-01-15T12:05:00Z",
      "isDeleted": false
    }
  ],
  "categories": [
    {
      "name": "Ăn uống",
      "type": "expense",
      "icon": "restaurant",
      "color": "0xFFFF9800",
      "updatedAt": "2025-01-15T10:00:00Z",
      "isDeleted": false
    }
  ]
}
```

### Lưu ý về các trường dữ liệu:
- **`id` (ObjectID)**: Nếu là bản ghi mới, hãy bỏ trống field này hoặc không gửi. Nếu là bản ghi cũ cần cập nhật, bắt buộc phải gửi `id` chính xác từ MongoDB.
- **`updatedAt`**: Sử dụng định dạng ISO8601 (`YYYY-MM-DDTHH:mm:ssZ`). Backend chỉ cập nhật nếu `updatedAt` gửi lên mới hơn dữ liệu trong DB.
- **`isDeleted`**: Để đồng bộ việc xóa, hãy gửi `isDeleted: true` thay vì xóa hẳn bản ghi ở client.

## 4. Phản hồi từ Server (Response)

### Thành công (200 OK)
```json
{
  "success": true,
  "message": "Đồng bộ dữ liệu và hình ảnh thành công"
}
```

### Thất bại (400 Bad Request - Lỗi Validation)
```json
{
  "success": false,
  "message": "Dữ liệu đầu vào không hợp lệ",
  "error": "Chi tiết lỗi vi phạm ràng buộc dữ liệu..."
}
```

### Lỗi xác thực (401 Unauthorized)
```json
{
  "success": false,
  "message": "Xác thực không hợp lệ hoặc đã hết hạn",
  "error": "jwt expired"
}
```

## 5. Ví dụ Code gọi từ Flutter (Dio)

```dart
var formData = FormData.fromMap({
  'data': jsonEncode(syncDataObject),
  'images': [
    await MultipartFile.fromFile('./path/to/image.png', filename: 'avatar.png')
  ],
});

var response = await dio.post('/api/sync', data: formData);
```

---

# Tài liệu API Lấy dữ liệu (Pull API)

Tài liệu này hướng dẫn cách lấy toàn bộ hoặc một phần dữ liệu từ Server về thiết bị.

## 1. Thông tin chung
- **Endpoint**: `/api/pull`
- **Method**: `GET`
- **Authentication**: `Bearer Token` (Header: `Authorization`)
- **Query Params**:
  - `since` (Optional): Thời điểm lấy dữ liệu gần nhất (định dạng ISO8601/RFC3339). Nếu gửi lên, server chỉ trả về dữ liệu có `updatedAt` lớn hơn hoặc bằng giá trị này. Ví dụ: `/api/pull?since=2026-03-04T00:45:00Z`

## 2. Phản hồi từ Server (Response)

### Thành công (200 OK)
Dữ liệu trả về sẽ bao gồm một trường `data` chứa các danh sách thực thể và trường `since` lưu thời điểm lấy dữ liệu hiện tại của hệ thống.

```json
{
  "data": {
    "users": [...],
    "accounts": [...],
    "categories": [...],
    "transactions": [...]
  },
  "since": "2026-03-04T00:45:00Z"
}
```

### Chi tiết các trường:
- **`accounts`**: Tương đương với `money_sources` trong cơ sở dữ liệu.
- **`since`**: Thời gian hiện tại của Server khi xử lý yêu cầu. Client **nên lưu lại** giá trị này để gửi vào param `since` ở lần gọi Pull tiếp theo nhằm tối ưu hóa băng thông.


## 3. Lỗi thường gặp
- **401 Unauthorized**: Token thiếu hoặc sai định dạng.
- **403 Forbidden**: Token hết hạn (`token_expired`), cần thực hiện Refresh Token.
