import React, { useState, useEffect } from 'react';
import DataTable from '../components/common/DataTable';
import Modal from '../components/common/Modal';
import { booksService } from '../services/booksService';
import '../styles/global.css';
import '../styles/BooksManagement.css';

const BooksManagement = () => {
  const [activeSection, setActiveSection] = useState(null);

  // --- حالات الكتب ---
  const [books, setBooks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filteredBooks, setFilteredBooks] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchType, setSearchType] = useState('title');

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBook, setEditingBook] = useState(null);
  const [formData, setFormData] = useState({
    author: '',
    title: '',
    description: '',
    price: '',
    book_type: 'paid',
    category_id: ''
  });
  

  const [selectedFile, setSelectedFile] = useState(null);

  const bookStats = {
    total: books.length,
    free: books.filter(b => b.is_free === 1).length,
    paid: books.filter(b => b.is_free === 0).length
  };

  // --- حالات الأقسام ---
  const [categories, setCategories] = useState([]);
  const [isCategoryModalOpen, setIsCategoryModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [formCategoryData, setFormCategoryData] = useState({ name: '' });

  // --- حالات الأسئلة ---
  const [questions, setQuestions] = useState([]);
  const [filteredQuestions, setFilteredQuestions] = useState([]);
  const [searchTypeQuestion, setSearchTypeQuestion] = useState('text');
  const [searchQuestionTerm, setSearchQuestionTerm] = useState('');
  const [searchBookId, setSearchBookId] = useState('');
  const [isQuestionModalOpen, setIsQuestionModalOpen] = useState(false);
  const [newQuestionText, setNewQuestionText] = useState('');
  const [selectedBookId, setSelectedBookId] = useState('');
  const [isEditQuestionModalOpen, setIsEditQuestionModalOpen] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState(null);
  const [editingQuestionText, setEditingQuestionText] = useState('');
// --- حالات Pagination للأسئلة ---
const [currentPage, setCurrentPage] = useState(1);
const [perPage, setPerPage] = useState(10);
const [lastPage, setLastPage] = useState(1);

// --- حالات الاجوبة ---
const [answers, setAnswers] = useState([]);
const [filteredAnswers, setFilteredAnswers] = useState([]);
const [answersPage, setAnswersPage] = useState(1);
const [answersLastPage, setAnswersLastPage] = useState(1);
const [loadingAnswers, setLoadingAnswers] = useState(false);
const [isAnswersModalOpen, setIsAnswersModalOpen] = useState(false);
// الحالة لتخزين السؤال المحدد مع جميع الإجابات

const [selectedQuestionWithAnswers, setSelectedQuestionWithAnswers] = useState(null);

const [answersForSelectedQuestion, setAnswersForSelectedQuestion] = useState([]);


const [allQuestions, setAllQuestions] = useState([]); // ← لحفظ نسخة كاملة من كل الأسئلة


// --- حالات مودالات الإجابات ---
const [showAddAnswerModal, setShowAddAnswerModal] = useState(false);
const [showEditAnswerModal, setShowEditAnswerModal] = useState(false);
const [selectedQuestionId, setSelectedQuestionId] = useState(null);
const [selectedAnswer, setSelectedAnswer] = useState(null);
const [answerText, setAnswerText] = useState("");
const [isCorrect, setIsCorrect] = useState(false);

  const questionStats = {
    totalQuestions: questions.length,
    correctAnswers: questions.filter(q => q.is_correct === 1).length,
    totalPoints: questions.reduce((sum, q) => sum + (q.points || 0), 0)
  };
// تحديث الإجابات لكل الأسئلة الظاهرة
const updateAnswersForVisibleQuestions = (questionsList) => {
  if (!questionsList || questionsList.length === 0) {
    setAnswersForSelectedQuestion([]);
    return;
  }
  const allAnswers = questionsList.flatMap(q => q.answers || []);
  setAnswersForSelectedQuestion(allAnswers);
};

//عواميد الجداول 
const bookColumns = [
  { key: 'id', title: 'ID' },
  { key: 'author', title: 'Author' },
  { key: 'title', title: 'Book Name' },
  { key: 'description', title: 'Description' },
  { key: 'price', title: 'Price' },
  { 
    key: 'book_type', 
    title: 'Book Type', 
    render: (value) => value === 'paid' ? 'Paid' : 'Free' 
  },
  { key: 'likes_count', title: 'Likes' },
  { 
    key: 'category', 
    title: 'Category',
    render: (value) => value || '-'  // يعرض القسم أو "-" إذا فارغ
  },
  {
    key: 'actions',
    title: 'Actions',
    render: (_, book) => (
      <div>
        <button className="btn-secondary" onClick={() => handleEditBook(book)}>Edit</button>
        <button className="btn-danger" onClick={() => handleDeleteBook(book)}>Delete</button>
      </div>
    )
  }
];

  const categoryColumns = [
    { key: 'id', title: 'ID' },
    { key: 'name', title: 'Category Name' },
    {
      key: 'actions',
      title: 'Actions',
      render: (_, category) => (
        <div>
          <button className="btn-danger" onClick={() => handleDeleteCategory(category)}>Delete</button>
        </div>
      )
    }
  ];

  const questionColumns = [
    { key: 'id', title: 'ID' },
    { key: 'text', title: 'Question Text' },
    { key: 'book_title', title: 'Book Name' },
    {
      key: 'actions',
      title: 'Actions',
      render: (_, question) => (
        <div>
          <button className="btn-secondary" onClick={() => openEditQuestionModal(question)}>Edit</button>
          <button className="btn-danger" onClick={() => handleDeleteQuestion(question)}>Delete</button>
          <button className="btn btn-primary" onClick={() => openAddAnswer(question.id)}>Add Answer</button>
          <button className="btn btn-primary" onClick={() => fetchQuestionWithAnswers(question.id)}>
          View The Answers
        </button>
        </div>
      )
    }
  ];

  
  const answerColumns = [
    { key: 'id', title: 'ID' },
    { key: 'answer_text', title: 'Answer Text' },
    { key: 'question_id', title: 'Question Id ' },
    { 
      key: 'is_correct', 
      title: ' False Or True',
      render: (value) => value ? " True" : " False"
    },
    {
      key: 'actions',
      title: 'Actions',
      render: (_, answer) => (
        <div>
          <button onClick={() => openEditAnswer(answer)} className="btn btn-warning">Edit</button>
          <button onClick={() => handleDeleteAnswer(answer.id)} className="btn btn-danger">Delete</button>
        </div>
      )
    }
  ];
  




  // --- التبديل بين الأقسام ---
  const handleBooks = () => setActiveSection('books');
  const handleQuestions = () => setActiveSection('questions');
  const handleCategories = () => setActiveSection('categories');


  // --- دوال إدارة الكتب ---
  const handleAddBook = () => {
    setEditingBook(null);
    setFormData({
      author: '',
      title: '',
      description: '',
      price: '',
      book_type: 'paid',
      category_id: ''
    });
        setIsModalOpen(true);
  };

  const handleEditBook = (book) => {
    setEditingBook(book);
    setFormData({
      author: book.author || '',
      title: book.title || '',
      description: book.description || '',
      price: book.price || '',
      book_type: book.book_type || 'paid',
      category_id: book.category_id || ''
    });
    
    setIsModalOpen(true);
  };

  const handleDeleteBook = async (book) => {
    const confirmDelete = window.confirm(
      `هل أنت متأكد من حذف الكتاب "${book.title}"؟`
    );
    if (!confirmDelete) return;
  
    try {
      await booksService.deleteBook(book.id);
  
      setBooks(prev => prev.filter(b => b.id !== book.id));
  
      alert("تم حذف الكتاب بنجاح");
    } catch (error) {
      console.error("خطأ أثناء حذف الكتاب:", error);
      alert("حدث خطأ أثناء حذف الكتاب");
    }
  };
  
  const handleSaveBook = async () => {
    const { author, title, description, price, book_type, category_id } = formData;
  
    if (!author || !title || !description || !price || !category_id) {
      alert('يرجى ملء جميع الحقول المطلوبة');
      return;
    }
  
    try {
      if (editingBook) {
        // 🔹 تعديل كتاب (JSON فقط)
        await booksService.updateBook(editingBook.id, {
          author,
          title,
          description,
          price: Number(price),
          book_type,
          category_id
        });
  
        alert('تم تعديل الكتاب بنجاح');
  
      } else {
        // 🔹 إضافة كتاب جديد (FormData)
        if (!selectedFile) {
          alert('يرجى اختيار ملف الكتاب');
          return;
        }
  
        const fd = new FormData();
        fd.append('author', author);
        fd.append('title', title);
        fd.append('description', description);
        fd.append('price', Number(price));
        fd.append('book_type', book_type);
        fd.append('file', selectedFile);
  
        await booksService.addBookToCategory(category_id, fd);
        alert('تم إضافة الكتاب بنجاح');
      }
  
      const updatedBooks = await booksService.getAllBooks();
      setBooks(updatedBooks.books || updatedBooks);
  
      setIsModalOpen(false);
      setEditingBook(null);
      setSelectedFile(null);
  
    } catch (error) {
      console.error('خطأ في حفظ الكتاب:', error);
      alert('حدث خطأ أثناء حفظ الكتاب');
    }
  };
  
  
  // --- دوال إدارة الأقسام ---
  const handleAddCategory = () => {
    setEditingCategory(null);
    setFormCategoryData({ name: '' });
    setIsCategoryModalOpen(true);
  };
  const handleSaveCategory = async () => {
    if (!formCategoryData.name) {
      alert('يرجى كتابة اسم القسم');
      return;
    }
    try {
      await booksService.addCategory({ name: formCategoryData.name });
  
      // بعد عملية الإضافة يجب جلب الأقسام من جديد
      const updated = await booksService.getAllCategories();
      setCategories(updated.categories || []);
  
      alert('تم إضافة القسم الجديد بنجاح');
      setIsCategoryModalOpen(false);
      setFormCategoryData({ name: '' });
    } catch (error) {
      console.error('Error adding category:', error);
      alert('حدث خطأ أثناء إضافة القسم');
    }
  };
  

  const handleDeleteCategory = async (category) => {
    const confirmDelete = window.confirm(
      ` تحذير!\nسيتم حذف القسم "${category.name}" وكل الكتب والأسئلة والأجوبة التابعة له.\nهل أنت متأكد؟`
    );
  
    if (!confirmDelete) return;
  
    try {
      // استدعاء API الحقيقي
      await booksService.deleteCategory(category.id);
  
      // تحديث الأقسام في الواجهة
      setCategories(prev => prev.filter(c => c.id !== category.id));
  
      // (اختياري) تحديث الكتب إذا كان قسم الكتب مفتوح
      if (activeSection === 'books' || activeSection === 'questions') {
        const booksData = await booksService.getAllBooks();
        setBooks(booksData.books || booksData);
      }
  
      alert(' تم حذف القسم وكل ما بداخله بنجاح');
  
    } catch (error) {
      console.error('Error deleting category:', error);
      alert(' حدث خطأ أثناء حذف القسم');
    }
  };
  

  // --- دوال إدارة الأسئلة ---
  const handleAddQuestion = async () => {
    if (!newQuestionText || !selectedBookId) {
      alert('يرجى كتابة السؤال واختيار الكتاب');
      return;
    }
  
    try {
      await booksService.addQuestion(selectedBookId, newQuestionText);
  
      // إعادة جلب الصفحة الحالية بعد الإضافة
      const res = await booksService.getPaginatedQuestions(currentPage, perPage);
  
      // التعديل هنا
      const list = res.list;        // ← التغيير هنا
      setLastPage(res.last_page);   // ← التغيير هنا
  
      const formatted = list.map(q => ({
        id: q.id,
        text: q.question_text,
        book_title: books.find(b => b.id === q.book_id)?.title || "غير معروف",
        book_id: q.book_id,
      }));
  
      setQuestions(formatted);
      setQuestions(formatted);
      setFilteredQuestions(formatted); // ← يفضل إضافة هذا أيضاً لتحديث الجدول مباشرة
     
      alert('تم إضافة السؤال بنجاح');
      setNewQuestionText('');
      setSelectedBookId('');
      setIsQuestionModalOpen(false);
  
    } catch (error) {
      console.error(error);
      alert('حدث خطأ أثناء إضافة السؤال');
    }
  };


  const openEditQuestionModal = (question) => {
    setEditingQuestion(question);
    setEditingQuestionText(question.text);
    setIsEditQuestionModalOpen(true);
  };
  const handleSaveEditQuestion = async () => {
    if (!editingQuestionText) {
      alert('يرجى كتابة السؤال');
      return;
    }
  
    try {
      await booksService.updateQuestion(editingQuestion.id, editingQuestionText);
  
      const res = await booksService.getPaginatedQuestions(currentPage, perPage);
  
      const list = res.list;        // ← التغيير هنا
      setLastPage(res.last_page);   // ← التغيير هنا
  
      const formatted = list.map(q => ({
        id: q.id,
        text: q.question_text,
        book_title: books.find(b => b.id === q.book_id)?.title || "غير معروف",
        book_id: q.book_id,
      }));
  
      
setAllQuestions(formatted);  // ← أضف هذا
setQuestions(formatted);
setFilteredQuestions(formatted);
  
      alert('تم تعديل السؤال بنجاح');
      setIsEditQuestionModalOpen(false);
      setEditingQuestion(null);
      setEditingQuestionText('');
  
    } catch (error) {
      console.error(error);
      alert('حدث خطأ أثناء تعديل السؤال');
    }
  };
  const handleDeleteQuestion = async (question) => {
    if (!window.confirm(`هل أنت متأكد من حذف السؤال "${question.text}"؟`)) return;
  
    try {
      await booksService.deleteQuestion(question.id);
  
      const res = await booksService.getPaginatedQuestions(currentPage, perPage);
  
      const list = res.list;        // ← التغيير هنا
     setLastPage(res.last_page);   // ← التغيير هنا
  
      const formatted = list.map(q => ({
        id: q.id,
        text: q.question_text,
        book_title: books.find(b => b.id === q.book_id)?.title || "غير معروف",
        book_id: q.book_id,
      }));
  
      
setAllQuestions(formatted);  // ← أضف هذا
setQuestions(formatted);
setFilteredQuestions(formatted);
  
      alert('تم حذف السؤال بنجاح');
  
    } catch (error) {
      console.error(error);
      alert('حدث خطأ أثناء حذف السؤال');
    }
  };

  // جلب أسئلة لكتاب محدد (باستخدام الـ API الجديد)
const fetchQuestionsByBook = async (bookId) => {
  if (!bookId) return;
  try {
    setLoading(true);
    const res = await booksService.getQuestionsByBook(bookId);
    // res.questions => array من الأسئلة
    const list = res.questions || [];
    const formatted = list.map(q => ({
      id: q.id,
      text: q.question_text,
      book_title: res.book?.title || books.find(b => b.id === q.book_id)?.title || "غير معروف",
      book_id: q.book_id,
    }));
    setQuestions(formatted);
    // هذه الـ API لا تعطي pagination (حسب ما أريتني) -> نضبط الصفحات على 1
    setCurrentPage(1);
    setLastPage(1);
  } catch (error) {
    console.error("Error fetching questions by book:", error);
  } finally {
    setLoading(false);
  }
};

// دالة ذكية لإعادة جلب الأسئلة حسب وضع الفلتر (إما paginated أو by-book)
const refetchQuestions = async (pageToFetch = 1) => {
  try {
    setLoading(true);

    if (searchTypeQuestion === 'book' && searchBookId) {
      await fetchQuestionsByBook(searchBookId);
    } else {
      const res = await booksService.getPaginatedQuestions(pageToFetch, perPage);
      const list = res.list || [];
      
      const formatted = list.map(q => ({
        id: q.id,
        text: q.question_text,
        book_title: books.find(b => b.id === q.book_id)?.title || "غير معروف",
        book_id: q.book_id,
        answers: q.answers || [], // حفظ الإجابات
      }));

      setAllQuestions(formatted); // ← ضع هذا قبل setQuestions
      setQuestions(formatted);
      setFilteredQuestions(formatted);                     // ← تحديث الجدول لجميع الأسئلة
      setLastPage(res.last_page || 1);
      setCurrentPage(res.current_page || pageToFetch);

      // ← تعيين السؤال الافتراضي وإجابات هذا السؤال
      setSelectedQuestionWithAnswers(formatted[0] || null);
      setAnswersForSelectedQuestion(formatted[0]?.answers || []);
    }

  } catch (err) {
    console.error("refetchQuestions error:", err);
  } finally {
    setLoading(false);
  }
};

// --- دالة لجلب سؤال مع جميع الإجابات ---
const fetchQuestionWithAnswers = async (questionId) => {
  try {
    const res = await booksService.getQuestionWithAnswers(questionId);
    const question = res.question;
    setSelectedQuestionWithAnswers({
      id: question.id,
      text: question.question_text,
      book_id: question.book_id,
      book_title: question.book?.title || books.find(b => b.id === question.book_id)?.title || "غير معروف"
    });
    setAnswersForSelectedQuestion(question.answers || []);
  } catch (error) {
    console.error("Error fetching question with answers:", error);
  }
};


  //دوال ادارة الاجوبة 
  const openAddAnswer = (questionId = null) => {
    setSelectedQuestionId(questionId);
    setAnswerText("");
    setIsCorrect(false);
    setShowAddAnswerModal(true);
  };
  
  
  const handleAddAnswer = async () => {

     // تحقق من اختيار السؤال
  if (!selectedQuestionId) {
    alert("يرجى اختيار السؤال أولاً");
    return;
  }

    try {
      const payload = {
        answer_text: answerText,
        is_correct: isCorrect,
      };

  // إرسال السؤال المختار مع الجواب
      await booksService.addAnswer(selectedQuestionId, payload);
  
      setShowAddAnswerModal(false);

      fetchAnswers(); // إعادة تحميل الإجابات
    } catch (error) {
      console.error("Error adding answer:", error);
    }
  };
  
  


  const openEditAnswer = (answer) => {
    setSelectedAnswer(answer);
    setAnswerText(answer.answer_text);
    setIsCorrect(answer.is_correct);
    setShowEditAnswerModal(true);
  };
  
  const handleEditAnswer = async () => {
    try {
      const payload = {
        answer_text: answerText,
        is_correct: isCorrect,
      };
  
      await booksService.updateAnswer(selectedAnswer.id, payload);
  
      setShowEditAnswerModal(false);
      fetchAnswers(); // إعادة تحميل الإجابات
    } catch (error) {
      console.error("Error updating answer:", error);
    }
  };
  


  const handleDeleteAnswer = async (answerId) => {
    if (!window.confirm("هل أنت متأكد من حذف الإجابة؟")) return;
  
    try {
      await booksService.deleteAnswer(answerId);
      fetchAnswers();
    } catch (error) {
      console.error("Error deleting answer:", error);
    }
  };
  const fetchAnswers = async () => {
    try {
      setLoadingAnswers(true);
  
      const res = await booksService.getPaginatedAnswers(answersPage, 10);
  
      setAnswers(res.data);
      setFilteredAnswers(res.data);
      setAnswersLastPage(res.meta.last_page);
  
    } catch (error) {
      console.error("Error fetching answers:", error);
    } finally {
      setLoadingAnswers(false);
    }
  };
  
  
  const goToPage = (page) => {
    if (page >= 1 && page <= lastPage) {
      setCurrentPage(page);
    }
  };


  // ====== دالة تغيير صفحة الإجابات ======
  const goToAnswersPage = (page) => {
    if (page >= 1 && page <= answersLastPage) {
      setAnswersPage(page); // ← هذا سيستدعي fetchAnswers تلقائيًا بسبب useEffect
    }
  };
  

  // --- useEffect ---


  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const categoriesData = await booksService.getAllCategories();
        setCategories(categoriesData);
      } catch (error) {
        console.error("Error fetching categories:", error);
      }
    };
  
    fetchCategories();
  }, []);
  
  // --- جلب الكتب عند فتح قسم Book Management ---
  useEffect(() => {
    const fetchBooks = async () => {
      try {
        setLoading(true);
        const booksData = await booksService.getAllBooks();
        setBooks(booksData.books || booksData);
      } catch (error) {
        console.error("Error fetching books:", error);
      } finally {
        setLoading(false);
      }
    };
  
    if (activeSection === "books" || activeSection === "questions") {
      fetchBooks();
    }
  }, [activeSection]);
// --- useEffect لجلب الأسئلة عند فتح صفحة الأسئلة أو تغيير الفلترة ---

  useEffect(() => {
    const fetchQuestionsForBook = async () => {
      try {
        setLoading(true);
    
        if (searchBookId) {
          const res = await booksService.getQuestionsByBook(searchBookId);
          const list = res.questions || [];
          const formatted = list.map(q => ({
            id: q.id,
            text: q.question_text,
            book_title: res.book?.title || books.find(b => b.id === q.book_id)?.title || "غير معروف",
            book_id: q.book_id,
            answers: q.answers || [],
          }));
          setAllQuestions(formatted);  // ← إضافة هنا
          setQuestions(formatted);
          setFilteredQuestions(formatted);
    
          if (formatted.length > 0) {
            setSelectedQuestionWithAnswers(formatted[0]);
            setAnswersForSelectedQuestion(formatted[0].answers || []);
          } else {
            setSelectedQuestionWithAnswers(null);
            setAnswersForSelectedQuestion([]); 
          }
    
          return;
        }
    
        const paginated = await refetchQuestions(1);
        setSelectedQuestionWithAnswers(paginated[0] || null);
        setAnswersForSelectedQuestion(paginated[0]?.answers || []);
    
      } catch (error) {
        console.error("Error fetching questions:", error);
      } finally {
        setLoading(false);
      }
    };
    
  
    if (activeSection === 'questions') {
      fetchQuestionsForBook();
    }
  }, [searchBookId, activeSection, books]);
  
  useEffect(() => {
    let filtered = books;
    if (searchTerm) {
      if (searchType === 'title') filtered = books.filter(b => b.title?.toLowerCase().includes(searchTerm.toLowerCase()));
      else if (searchType === 'author') filtered = books.filter(b => b.author?.toLowerCase().includes(searchTerm.toLowerCase()));
    }
    setFilteredBooks(filtered);
  }, [books, searchTerm, searchType]);


  // عند فتح قسم الأسئلة لأول مرة
  useEffect(() => {
    if (activeSection === 'questions') {
      // جلب جميع الأسئلة مرة واحدة عند فتح القسم
      refetchQuestions(1);
    }
  }, [activeSection,books]);
  


// راقب تغيّر الفلترة والصفحات
useEffect(() => {
  if (activeSection !== 'questions') return;

  if (searchTypeQuestion === "book") {
    if (searchBookId) {
      const filtered = allQuestions.filter(q => q.book_id === parseInt(searchBookId));
      setFilteredQuestions(filtered);
      setSelectedQuestionWithAnswers(filtered[0] || null);
      setAnswersForSelectedQuestion(filtered[0]?.answers || []);
    } else {
      // لا يوجد فلتر على الكتاب → عرض كل الأسئلة
      setFilteredQuestions(allQuestions);
      updateAnswersForVisibleQuestions(allQuestions);
      setSelectedQuestionWithAnswers(null);
      setAnswersForSelectedQuestion(allQuestions.flatMap(q => q.answers || [])); // ← تعديل هنا
    }
    return;
  }

  if (searchTypeQuestion === "text" && searchQuestionTerm) {
    const filtered = allQuestions.filter(q =>
      q.text.toLowerCase().includes(searchQuestionTerm.toLowerCase())
    );
    setFilteredQuestions(filtered);
    updateAnswersForVisibleQuestions(filtered);
    setSelectedQuestionWithAnswers(null);
    setAnswersForSelectedQuestion(filtered.flatMap(q => q.answers || []));
  } else {
    // أي تغيير آخر في نوع الفلترة → إعادة جميع الأسئلة
    setFilteredQuestions(allQuestions);
    updateAnswersForVisibleQuestions(allQuestions);
    setSelectedQuestionWithAnswers(null);
    setAnswersForSelectedQuestion(allQuestions.flatMap(q => q.answers || [])); // ← تعديل هنا
  }
}, [searchTypeQuestion, searchBookId, searchQuestionTerm, currentPage, allQuestions]);

useEffect(() => {
  if (activeSection === 'questions') {
    const fetchAnswers = async () => {
      try {
        setLoadingAnswers(true);
    
        // استدعاء الـ API
        const res = await booksService.getPaginatedAnswers(answersPage, 10);
    
        // تحديث الـ state
        setAnswers(res.data);
        setFilteredAnswers(res.data);
        setAnswersLastPage(res.meta.last_page);
    
      } catch (error) {
        console.error("Error fetching answers:", error);
      } finally {
        setLoadingAnswers(false);
      }
    };
    

    fetchAnswers();
  }
}, [activeSection, answersPage]);

useEffect(() => {
  if (activeSection !== 'questions') return;

  // إذا تم تغيير نوع الفلترة إلى "text" (بحث عن السؤال)
  if (searchTypeQuestion === "text") {
    // إعادة جلب الأسئلة من API (paginated)
    refetchQuestions(1);

    // مسح أي فلترة على الكتاب
    setSearchBookId(""); 
  }
}, [searchTypeQuestion, activeSection]);





  
  return (
    <div className="books-management">
    <div className="page-header">
      <h1>Books Management</h1>

      {activeSection === 'books' && (
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="btn-primary add-book-btn" onClick={handleAddBook}>
            + Add New Book
          </button>

          <button className="btn-primary add-book-btn" onClick={handleAddCategory}>
            + add new category
          </button>
        </div>
      )}

      {activeSection === 'questions' && (
        <div style={{ display: 'flex', gap: '10px' }}>
        <button className="btn-primary add-book-btn" onClick={() => setIsQuestionModalOpen(true)}>
          + Add New Question
        </button>
    
        <button className="btn-primary add-book-btn" onClick={() => openAddAnswer(null)}>
  + Add New Answer
</button>

      </div>
      )}

    </div>
    <div className="main-stats" style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
  <div className="stat-card">
    <h3>Total Number Of Books</h3>
    <span className="stat-number">{bookStats.total}</span>
  </div>
  <div className="stat-card">
    <h3>Total Number Of Questions</h3>
    <span className="stat-number">{questionStats.totalQuestions}</span>
  </div>
</div>

      <div className="buttons-container">
        
        <button className={`btn ${activeSection === 'books' ? 'btn-primary' : 'btn-outline'}`} onClick={handleBooks}>
          Book Management
        </button>
        <button className={`btn ${activeSection === 'questions' ? 'btn-primary' : 'btn-outline'}`} onClick={handleQuestions}>
          Questions And Answers
        </button>
        
      </div>
  
      {/* قسم إدارة الكتب */}
      {activeSection === 'books' && (
  <div className="books-section">

    <div className="section-header">
      <h2>Book Management Section</h2>

      <div style={{ display: 'flex', gap: '10px' }}>
        
      </div>
    </div>

  
         
  
          <div className="books-filters">
            <div className="search-section">
              <input
                type="text"
                placeholder="Search For The Book Title Or Author's Name"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="search-input"
              />
            </div>
  
            <div className="filter-section">
              <select value={searchType} onChange={(e) => setSearchType(e.target.value)} className="filter-select">
                <option value="title">Search For The Book Title</option>
                <option value="author">Search For The Author's Name</option>
              </select>
            </div>
  
            <div className="filter-section">
              <button className="btn-secondary" onClick={() => setSearchTerm('')}>View All Books</button>
            </div>
  
            <div className="results-count">
              Show {filteredBooks.length} Out Of {books.length} Books
            </div>

          </div>

          <div className="section-header" style={{ marginTop: '40px' }}>
              <h3>Available Books </h3>
          </div>
          <DataTable columns={bookColumns} data={searchTerm ? filteredBooks : books} loading={loading} />


          {/* جدول الأقسام */}
            <div className="section-header" style={{ marginTop: '40px' }}>
              <h3>Available Sections </h3>
          </div>

          <DataTable
            columns={categoryColumns}
            data={categories}
            loading={false}
          />

        </div>
      )}
  
     
  
    {/* قسم إدارة الأسئلة */}
{activeSection === 'questions' && (
  <div className="questions-section">
    <div className="section-header">
      <h2>Questions and Answers Section</h2>
    </div>

   

    <div className="questions-filters">
      <div className="filter-section">
        <select value={searchTypeQuestion} onChange={(e) => setSearchTypeQuestion(e.target.value)} className="filter-select">
          <option value="text">Search For A Question</option>
          <option value="book">Search By Book</option>
        </select>
      </div>

      {searchTypeQuestion === 'text' && (
  <div className="filter-section">
    <select
      value={selectedQuestionId || ""}
      onChange={(e) => {
        const qId = e.target.value;
        setSelectedQuestionId(qId);
        if (qId) {
          fetchQuestionWithAnswers(qId); // جلب جميع الإجابات للسؤال المختار
          const selectedQ = questions.find(q => q.id === parseInt(qId));
          setFilteredQuestions(selectedQ ? [selectedQ] : []);
        } else {
          setFilteredQuestions(questions); // عرض كل الأسئلة
          setAnswersForSelectedQuestion([]); // عرض كل الإجابات حسب pagination
        }
      }}
      className="filter-select"
    >
      <option value="">-- Choose One Question  --</option>
      {questions.map(q => (
        <option key={q.id} value={q.id}>
          {q.text.slice(0, 50)}...
        </option>
      ))}
    </select>
  </div>
)}


      {searchTypeQuestion === 'book' && (
        <div className="filter-section">
          <select value={searchBookId} onChange={(e) => setSearchBookId(e.target.value)} className="filter-select">
            <option value="">-- Choose One Book  --</option>
            {books.map(book => (
              <option key={book.id} value={book.id}>{book.title}</option>
            ))}
          </select>
        </div>
      )}
    </div>
    <div className="answers-section" style={{ marginTop: '40px' }}>
      <h3>Quesions  List</h3>
</div>
    <DataTable columns={questionColumns} data={filteredQuestions} loading={loading} />
    
    <div className="pagination">
      <button onClick={() => goToPage(currentPage - 1)} disabled={currentPage === 1}>
        « Prev
      </button>

      {Array.from({ length: lastPage }, (_, i) => (
        <button
          key={i + 1}
          onClick={() => goToPage(i + 1)}
          className={currentPage === i + 1 ? 'active' : ''}
        >
          {i + 1}
        </button>
      ))}

      <button onClick={() => goToPage(currentPage + 1)} disabled={currentPage === lastPage}>
        Next »
      </button>
    </div>

    {/* ====== جدول الإجابات أسفل الأسئلة ====== */}


    <div className="answers-section" style={{ marginTop: '40px' }}>
      <h3>Answers List</h3>

      <DataTable 
        columns={answerColumns}
        data={selectedQuestionWithAnswers
          ? answersForSelectedQuestion   // إذا اختار المستخدم سؤال
          : answers                     // إذا لم يختر أي سؤال → عرض كل الإجابات
              }
        loading={loadingAnswers}
      />

      <div className="pagination">
        <button onClick={() => goToAnswersPage(answersPage - 1)} disabled={answersPage === 1}>
          « Prev
        </button>

        {Array.from({ length: answersLastPage }, (_, i) => (
          <button
            key={i + 1}
            onClick={() => goToAnswersPage(i + 1)}
            className={answersPage === i + 1 ? 'active' : ''}
          >
            {i + 1}
          </button>
        ))}

        <button onClick={() => goToAnswersPage(answersPage + 1)} disabled={answersPage === answersLastPage}>
              Next »
        </button>
      </div>
    </div>

  </div>
)}


      
      
  
      {/* مودال إضافة / تعديل كتاب */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setEditingBook(null); }}
        title={editingBook ? "تعديل كتاب" : "Add New Book"}
      >
        <div className="book-form">
          <div className="form-group">
            <label>Author *</label>
            <input type="text" value={formData.author} onChange={(e) => setFormData({ ...formData, author: e.target.value })} required />
          </div>
          <div className="form-group">
            <label> Book Title *</label>
            <input type="text" value={formData.title} onChange={(e) => setFormData({ ...formData, title: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>Description *</label>
            <textarea value={formData.description} onChange={(e) => setFormData({ ...formData, description: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>Price *</label>
            <input type="number" value={formData.price} onChange={(e) => setFormData({ ...formData, price: e.target.value })} required />
          </div>
          <div className="form-group">
            <label>Free.?</label>
            <select value={formData.is_free} onChange={(e) => setFormData({ ...formData, is_free: parseInt(e.target.value) })}>
              <option value={0}>No </option>
              <option value={1}>Yes</option>
            </select>
          </div>

          <div className="form-group">
  <label>Book Type</label>
  <select 
    value={formData.book_type} 
    onChange={(e) => setFormData({...formData, book_type: e.target.value})}
    className="form-input"
  >
    <option value="paid">For Paid</option>
    <option value="free">For Free</option>
  </select>
</div>

          
          <div className="form-group">
            <label>Section *</label>
            <select value={formData.sectionid} onChange={(e) => setFormData({ ...formData, category_id: e.target.value })} required>
              <option value="">-- Choose one Section --</option>
              {categories.map(cat => (<option key={cat.id} value={cat.id}>{cat.name}</option>))}
            </select>
          </div>
          
          {/* حقل رفع الملف المضاف */}
          <div className="form-group">
            <label>Upload The Book File  (PDF) *</label>
            <input 
              type="file" 
              accept=".pdf"
              onChange={(e) => setSelectedFile(e.target.files[0])}
              className="form-input"
              required
            />
            {selectedFile && <span style={{color: 'green'}}>✓ The Choice Is Made : {selectedFile.name}</span>}
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>Cancel</button>
            <button className="btn-primary" onClick={handleSaveBook}>{editingBook ? "حفظ التعديل" : "Add Book"}</button>
          </div>
        </div>
      </Modal>
  
      {/* مودال إضافة / تعديل قسم */}
      <Modal
        isOpen={isCategoryModalOpen}
        onClose={() => { setIsCategoryModalOpen(false); setFormCategoryData({ name: '' }); }}
        title="Add New Section"
      >
        <div className="category-form">
          <div className="form-group">
            <label>: Section's Name *</label>
            <input type="text" value={formCategoryData.name} onChange={(e) => setFormCategoryData({ ...formCategoryData, name: e.target.value })} required />
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsCategoryModalOpen(false)}>Cancel</button>
            <button className="btn-primary" onClick={handleSaveCategory}>Add Section</button>
          </div>
        </div>
      </Modal>
  
      {/* مودال إضافة سؤال جديد */}
      <Modal
        isOpen={isQuestionModalOpen}
        onClose={() => setIsQuestionModalOpen(false)}
        title=" Add New Question"
      >
        <div className="question-form">
          <div className="form-group">
            <label>Question Title *</label>
            <textarea value={newQuestionText} onChange={(e) => setNewQuestionText(e.target.value)} required></textarea>
          </div>
          <div className="form-group">
            <label>Choose The Book *</label>
            <select value={selectedBookId} onChange={(e) => setSelectedBookId(e.target.value)}>
              <option value="">-- Choose One Book  --</option>
              {books.map(book => (<option key={book.id} value={book.id}>{book.title}</option>))}
            </select>
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsQuestionModalOpen(false)}>Cancel</button>
            <button className="btn-primary" onClick={handleAddQuestion}>Add Queston</button>
          </div>
        </div>
      </Modal>
  
      {/* مودال تعديل سؤال */}
      <Modal
        isOpen={isEditQuestionModalOpen}
        onClose={() => setIsEditQuestionModalOpen(false)}
        title="تعديل السؤال"
      >
        <div className="question-form">
          <div className="form-group">
            <label>السؤال *</label>
            <textarea value={editingQuestionText} onChange={(e) => setEditingQuestionText(e.target.value)} required></textarea>
          </div>
          <div className="form-actions">
            <button className="btn-secondary" onClick={() => setIsEditQuestionModalOpen(false)}>إلغاء</button>
            <button className="btn-primary" onClick={handleSaveEditQuestion}>حفظ</button>
          </div>
        </div>
      </Modal>


      {/* مودال إضافة / تعديل جواب */}
<Modal
  isOpen={showAddAnswerModal || showEditAnswerModal}
  onClose={() => {
    setShowAddAnswerModal(false);
    setShowEditAnswerModal(false);
    setSelectedAnswer(null);
    setAnswerText("");
    setIsCorrect(false);
  }}
  title={selectedAnswer ? "تعديل جواب" : " Add New Answer "}
><div className="answer-form">
  {/* اختيار السؤال أولاً */}
  <div className="form-group">
    <label>Choose The Question  *</label>
    <select 
      value={selectedQuestionId || ""} 
      onChange={(e) => setSelectedQuestionId(e.target.value)} 
      required
    >
      <option value="">-- Choose One Question  --</option>
      {questions.map(q => (
        <option key={q.id} value={q.id}>
          {q.id} - {q.text.slice(0, 50)}...
        </option>
      ))}
    </select>
  </div>

  {/* حقل نص الجواب */}
  <div className="form-group">
    <label>Answer Title  *</label>
    <input
      type="text"
      value={answerText}
      onChange={(e) => setAnswerText(e.target.value)}
      required
    />
  </div>

{/* checkbox صحيح */}
<div className="checkbox-inline">
  <input
    type="checkbox"
    checked={isCorrect}
    onChange={(e) => setIsCorrect(e.target.checked)}
    id="isCorrect"
  />
  <label htmlFor="isCorrect">Correct</label>
</div>




  {/* أزرار حفظ / إلغاء */}
  <div className="form-actions">
    <button className="btn-secondary" onClick={() => {
      setShowAddAnswerModal(false);
      setShowEditAnswerModal(false);
      setSelectedAnswer(null);
      setAnswerText("");
      setIsCorrect(false);
    }}>Cancel</button>

    <button className="btn-primary" onClick={selectedAnswer ? handleEditAnswer : handleAddAnswer}>
      {selectedAnswer ? "تعديل" : "Add Answer"}
    </button>
  </div>
</div>

</Modal>

    </div>
  );
  
};

export default BooksManagement
