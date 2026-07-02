// 文件操作
import fs from "@ohos.file.fs";
import http from "@ohos.net.http";

// ========== 全部类型接口，嵌套结构单独拆分 ==========
// 上传表单结构
interface UploadFormData {
  file: ArrayBuffer;
}
// 请求头结构
interface UploadHeader {
  "Content-Type": string;
}
// 后端返回data内部结构（单独拆分为子接口）
interface UploadRespData {
  fileUrl: string;
}
// 完整上传接口返回外层结构
interface UploadResponse {
  data: UploadRespData;
  code: number;
  msg: string;
}

export default class CloudFileService {
  // 单张图片http表单上传
  static async uploadPetPhoto(localPath: string): Promise<string> {
    const httpRequest = http.createHttp();
    const uploadUrl = "https://xxx-cloud-storage.com/petAlbum";

    let fileData: ArrayBuffer = new ArrayBuffer(0);
    let fileObj: fs.File | null = null;
    try {
      fileObj = fs.openSync(localPath, fs.OpenMode.READ_ONLY);
      const fd: number = fileObj.fd;
      const stat = fs.statSync(localPath);
      const fileSize = stat.size;
      fileData = new ArrayBuffer(fileSize);
      fs.readSync(fd, fileData);
    } finally {
      if (fileObj !== null) {
        fs.closeSync(fileObj.fd);
      }
    }

    // 强类型约束对象字面量
    const formData: UploadFormData = {
      file: fileData
    };
    const header: UploadHeader = {
      "Content-Type": "multipart/form-data"
    };

    try {
      const res = await httpRequest.request(uploadUrl, {
        method: http.RequestMethod.POST,
        header: header,
        extraData: formData,
        connectTimeout: 10000
      });
      // 显式强类型解析JSON，消除any/unknown
      const result: UploadResponse = JSON.parse(res.result as string) as UploadResponse;
      return result.data.fileUrl;
    } catch (rawErr) {
      console.error("图片上传失败：", JSON.stringify(rawErr));
      const errMsg = typeof rawErr === "object" ? JSON.stringify(rawErr) : String(rawErr);
      throw new Error("图片上传异常：" + errMsg);
    } finally {
      httpRequest.destroy();
    }
  }

  // 批量上传相册图片
  static async batchUploadPhoto(fileList: string[]): Promise<string[]> {
    let urlList: string[] = [];
    for (const path of fileList) {
      // 修复：静态方法调用静态方法，使用 类名.方法名，不能用this
      const cloudUrl = await CloudFileService.uploadPetPhoto(path);
      urlList.push(cloudUrl);
    }
    return urlList;
  }
}