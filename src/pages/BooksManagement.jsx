// src/pages/BooksManagement.jsx
import React, { useState, useEffect } from "react"
import DataTable from "../components/common/DataTable"
import "../styles/BooksManagement.css"

const BooksManagement = () => {
  const [activeTab, setActiveTab] = useState("content");
  const [loading, setLoading] = useState(true);
  
  // بيانات الجداول (فارغة)
  const [booksData, setBooksData] = useState([]);
  const [bookRequestsData, setBookRequestsData] = useState([]);
  const [questionsData, setQuestionsData] = useState([]);

  // أعمدة إدارة محتوى الكتب
  const booksColumns = [
    { key: "id", label: "ID" },
    { key: "author", label: "المؤلف" },
    { key: "title", label: "العنوان" },
    { key: "description", label: "الوصف" },
    { key: "price", label: "السعر" },
    { key: "is_free", label: "مجاني" },
    { key: "book_type", label: "نوع الكتاب" },
    { key: "discount_rate", label: "معدل الخصم" },
    { key: "sectionid", label: "القسم" },
    { key: "actions", label: "الإجراءات" }
  ];

  // أعمدة طلبات الكتب
  const bookRequestsColumns = [
    { key: "id", label: "ID" },
    { key: "request_details", label: "تفاصيل الطلب" },
    { key: "status", label: "الحالة" },
    { key: "created_at", label: "تاريخ الطلب" },
    { key: "actions", label: "الإجراءات" }
  ];

  // أعمدة الأسئلة والأجوبة
  const questionsColumns = [
    { key: "id", label: "ID" },
    { key: "question_id", label: "رقم السؤال" },
    { key: "book_id", label: "رقم الكتاب" },
    { key: "title", label: "العنوان" },
    { key: "questions_count", label: "عدد الأسئلة" },
    { key: "points_earned", label: "النقاط المكتسبة" },
    { key: "text", label: "النص" },
    { key: "is_correct", label: "صحيح" },
    { key: "actions", label: "الإجراءات" }
  ];

  // محاكاة جلب البيانات من API
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        await new Promise(resolve => setTimeout(resolve, 1000));
        // بيانات فارغة
        setBooksData([]);
        setBookRequestsData([]);
        setQuestionsData([]);
      } catch (error) {
        console.error("Error fetching data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // دوال إدارة محتوى الكتب
  const handleAddBook = () => {
    console.log("طلب API - إضافة كتاب");
    alert("طلب إضافة كتاب سيتم إرساله للباكند");
  };

  const handleEditBook = (row) => {
    console.log("طلب API - تعديل كتاب:", row);
    alert(`طلب تعديل كتاب (ID: ${row.id}) سيتم إرساله للباكند`);
  };

  const handleDeleteBook = (row) => {
    console.log("طلب API - حذف كتاب:", row);
    if (window.confirm(`هل تريد حذف الكتاب "${row.title}"؟`)) {
      alert(`طلب حذف كتاب (ID: ${row.id}) سيتم إرساله للباكند`);
    }
  };

  // دوال طلبات الكتب
  const handleAddBookRequest = () => {
    console.log("طلب API - إضافة طلب كتاب");
    alert("طلب إضافة طلب كتاب سيتم إرساله للباكند");
  };

  const handleEditBookRequest = (row) => {
    console.log("طلب API - تعديل طلب كتاب:", row);
    alert(`طلب تعديل طلب كتاب (ID: ${row.id}) سيتم إرساله للباكند`);
  };

  const handleDeleteBookRequest = (row) => {
    console.log("طلب API - حذف طلب كتاب:", row);
    if (window.confirm("هل تريد حذف طلب الكتاب؟")) {
      alert(`طلب حذف طلب كتاب (ID: ${row.id}) سيتم إرساله للباكند`);
    }
  };

  // دوال الأسئلة والأجوبة
  const handleAddQuestion = () => {
    console.log("طلب API - إضافة سؤال جديد");
    alert("طلب إضافة سؤال جديد سيتم إرساله للباكند");
  };

  const handleEditQuestion = (row) => {
    console.log("طلب API - تعديل سؤال:", row);
    alert(`طلب تعديل سؤال (ID: ${row.id}) سيتم إرساله للباكند`);
  };

  const handleDeleteQuestion = (row) => {
    console.log("طلب API - حذف سؤال:", row);
    if (window.confirm("هل تريد حذف السؤال؟")) {
      alert(`طلب حذف سؤال (ID: ${row.id}) سيتم إرساله للباكند`);
    }
  };

  return (
    <div className="books-management-page">
      <div className="books-header">
        <h2 className="page-title">إدارة الكتب</h2>
        <p className="page-description">إدارة محتوى الكتب وطلباتها والأسئلة المتعلقة بها</p>
      </div>

      {/* أزرار التبويب */}
      <div className="books-tabs">
        <button 
          className={`tab-btn ${activeTab === "content" ? "active" : ""}`}
          onClick={() => setActiveTab("content")}
        >
          📚 إدارة محتوى الكتب
        </button>
        <button 
          className={`tab-btn ${activeTab === "requests" ? "active" : ""}`}
          onClick={() => setActiveTab("requests")}
        >
          📋 إدارة طلبات الكتب
        </button>
        <button 
          className={`tab-btn ${activeTab === "questions" ? "active" : ""}`}
          onClick={() => setActiveTab("questions")}
        >
          ❓ الأسئلة والأجوبة
        </button>
      </div>

      {/* محتوى التبويب النشط */}
      <div className="tab-content">
        
        {/* إدارة محتوى الكتب */}
        {activeTab === "content" && (
          <div className="content-management">
            {!loading ? (
              <DataTable
                title="قائمة الكتب"
                columns={booksColumns}
                data={booksData}
                onAdd={handleAddBook}
                onEdit={handleEditBook}
                onDelete={handleDeleteBook}
                emptyMessage="لا توجد كتب متاحة"
              />
            ) : (
              <div className="loading-container">
                <div className="loading-spinner"></div>
                <p>جاري تحميل الكتب...</p>
              </div>
            )}
          </div>
        )}

        {/* إدارة طلبات الكتب */}
        {activeTab === "requests" && (
          <div className="requests-management">
            {!loading ? (
              <DataTable
                title="طلبات الكتب"
                columns={bookRequestsColumns}
                data={bookRequestsData}
                onAdd={handleAddBookRequest}
                onEdit={handleEditBookRequest}
                onDelete={handleDeleteBookRequest}
                emptyMessage="لا توجد طلبات كتب"
              />
            ) : (
              <div className="loading-container">
                <div className="loading-spinner"></div>
                <p>جاري تحميل طلبات الكتب...</p>
              </div>
            )}
          </div>
        )}

        {/* الأسئلة والأجوبة */}
        {activeTab === "questions" && (
          <div className="questions-management">
            {!loading ? (
              <DataTable
                title="الأسئلة والأجوبة"
                columns={questionsColumns}
                data={questionsData}
                onAdd={handleAddQuestion}
                onEdit={handleEditQuestion}
                onDelete={handleDeleteQuestion}
                emptyMessage="لا توجد أسئلة متاحة"
              />
            ) : (
              <div className="loading-container">
                <div className="loading-spinner"></div>
                <p>جاري تحميل الأسئلة...</p>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default BooksManagement