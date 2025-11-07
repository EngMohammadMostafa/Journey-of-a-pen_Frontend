import axios from 'axios'

  const API_BASE_URL = 'http://localhost:8000/api'
  
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000, // زيادة الـ timeout
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    
    console.log('🚀 إرسال طلب إلى:', config.baseURL + config.url);
    return config;
  },
  (error) => {
    console.error('❌ خطأ في إعداد الطلب:', error);
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    console.log('✅ استجابة ناجحة من:', response.config.url);
    return response;
  },
  (error) => {
    console.error('❌ خطأ في الاتصال:', {
      message: error.message,
      code: error.code,
      url: error.config?.baseURL + error.config?.url
    });
    
    if (error.code === 'ECONNABORTED') {
      console.error('⏰ انتهت مهلة الاتصال. تأكد من:');
      console.error('1. تشغيل الباكند على البورت 8000');
      console.error('2. العنوان الصحيح:', error.config?.baseURL);
      console.error('3. عدم وجود جدار ناري يمنع الاتصال');
    }
    
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_user');
      window.location.href = '/login';
    }
    
    return Promise.reject(error);
  }
);

export default api  



// const api = axios.create({
//   baseURL: API_BASE_URL,
//   timeout: 15000,
//   headers: {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json'
//   }
// });

// // ✅ إضافة interceptor للتشخيص
// api.interceptors.request.use(
//   (config) => {
//     const token = localStorage.getItem('admin_token');
//     if (token) {
//       config.headers.Authorization = `Bearer ${token}`;
//     }
    
//     console.log('🚀 إرسال طلب إلى:', {
//       url: config.url,
//       method: config.method,
//       data: config.data,
//       headers: config.headers
//     });
    
//     return config;
//   },
//   (error) => {
//     console.error('❌ خطأ في إعداد الطلب:', error);
//     return Promise.reject(error);
//   }
// );

// // ✅ معالجة أخطاء الاستجابة بشكل مفصل
// api.interceptors.response.use(
//   (response) => {
//     console.log('✅ استجابة ناجحة:', {
//       url: response.config.url,
//       status: response.status,
//       data: response.data
//     });
//     return response;
//   },
//   (error) => {
//     // ✅ تشخيص مفصل للخطأ
//     console.error('❌ خطأ مفصل في الاستجابة:', {
//       message: error.message,
//       code: error.code,
//       status: error.response?.status,
//       statusText: error.response?.statusText,
//       data: error.response?.data,
//       config: {
//         url: error.config?.url,
//         method: error.config?.method
//       }
//     });
    
//     if (error.code === 'NETWORK_ERROR' || error.code === 'ECONNREFUSED') {
//       console.error('🔌 مشكلة في الاتصال بالخادم - تأكد من:');
//       console.error('1. أن الخادم يعمل على البورت 8000');
//       console.error('2. أن العنوان IP صحيح');
//       console.error('3. عدم وجود جدار ناري يمنع الاتصال');
//     }
    
//     if (error.response?.status === 401) {
//       localStorage.removeItem('admin_token');
//       localStorage.removeItem('admin_user');
//       window.location.href = '/login';
//     }
    
//     return Promise.reject(error);
//   }
// );

// export default api