import React, { useEffect, useState } from "react";

const DashboardLayout = ({ children }) => {
  const [scrollOpacity, setScrollOpacity] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      const y = window.scrollY;
      // عند الصعود للأعلى تصبح شفافة تدريجيًا
      const opacity = Math.min(y / 150, 1);
      setScrollOpacity(opacity);
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <>
      {/* طبقة شفافة أعلى المحتوى */}
      <div
        className="scroll-fade-layer"
        style={{ opacity: scrollOpacity }}
      ></div>

<div className="dashboard-wrapper" style={{ marginTop: "90px" }}>
  {children}
</div>

    </>
  );
};

export default DashboardLayout;
