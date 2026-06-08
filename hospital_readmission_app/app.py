import joblib
import numpy as np
import pandas as pd
import streamlit as st
from pathlib import Path

# Compatibility fix for sklearn ColumnTransformer pickle loading
import sklearn.compose._column_transformer as sklearn_column_transformer

if not hasattr(sklearn_column_transformer, "_RemainderColsList"):
    class _RemainderColsList(list):
        pass

    sklearn_column_transformer._RemainderColsList = _RemainderColsList


# ============================================================
# Page Config
# ============================================================

st.set_page_config(
    page_title="Hospital Readmission Risk Demo",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)


# ============================================================
# Custom CSS - Soft Rose Medical Theme
# ============================================================

st.markdown(
    """
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

    html, body, [class*="css"] {
        font-family: 'Inter', sans-serif;
    }

    .stApp {
        background:
            radial-gradient(circle at 15% 10%, rgba(255, 182, 193, 0.35), transparent 28%),
            radial-gradient(circle at 85% 20%, rgba(191, 219, 254, 0.45), transparent 30%),
            linear-gradient(180deg, #fff7f9 0%, #fffafc 45%, #f8fbff 100%);
        color: #182235;
    }

    .block-container {
        padding-top: 2rem;
        padding-bottom: 3rem;
        max-width: 1120px;
    }

    [data-testid="stSidebar"] {
        background:
            linear-gradient(180deg, rgba(255, 245, 248, 0.95) 0%, rgba(241, 247, 255, 0.92) 100%);
        border-right: 1px solid rgba(244, 114, 182, 0.16);
        box-shadow: 8px 0 30px rgba(148, 163, 184, 0.12);
    }

    [data-testid="stSidebar"] * {
        color: #1f2937;
    }

    .hero-card {
        background:
            linear-gradient(135deg, rgba(255, 255, 255, 0.92) 0%, rgba(255, 241, 246, 0.88) 55%, rgba(239, 246, 255, 0.9) 100%);
        padding: 2.4rem 2.5rem;
        border-radius: 30px;
        color: #172033;
        box-shadow:
            0 24px 60px rgba(244, 114, 182, 0.18),
            0 10px 30px rgba(59, 130, 246, 0.10);
        margin-bottom: 1.8rem;
        border: 1px solid rgba(255, 255, 255, 0.88);
        position: relative;
        overflow: hidden;
    }

    .hero-card::before {
        content: "";
        position: absolute;
        top: -90px;
        right: -80px;
        width: 260px;
        height: 260px;
        background: radial-gradient(circle, rgba(244, 114, 182, 0.35), transparent 62%);
        filter: blur(2px);
    }

    .hero-card::after {
        content: "";
        position: absolute;
        bottom: -100px;
        left: -90px;
        width: 300px;
        height: 300px;
        background: radial-gradient(circle, rgba(96, 165, 250, 0.25), transparent 65%);
    }

    .hero-title {
        font-size: 2.7rem;
        font-weight: 850;
        line-height: 1.08;
        margin-bottom: 0.85rem;
        letter-spacing: -0.04em;
        color: #172033;
        position: relative;
        z-index: 1;
    }

    .hero-subtitle {
        font-size: 1.05rem;
        line-height: 1.75;
        color: #475569;
        max-width: 780px;
        position: relative;
        z-index: 1;
    }

    .pill {
        display: inline-block;
        padding: 0.38rem 0.82rem;
        border-radius: 999px;
        background: rgba(255, 255, 255, 0.75);
        color: #be185d;
        font-size: 0.82rem;
        font-weight: 700;
        margin-right: 0.5rem;
        margin-bottom: 0.7rem;
        border: 1px solid rgba(244, 114, 182, 0.28);
        box-shadow: 0 8px 18px rgba(244, 114, 182, 0.10);
        position: relative;
        z-index: 1;
    }

    .section-card {
        background: rgba(255, 255, 255, 0.78);
        padding: 1.35rem 1.5rem;
        border-radius: 24px;
        border: 1px solid rgba(244, 114, 182, 0.14);
        box-shadow:
            0 14px 36px rgba(148, 163, 184, 0.12),
            inset 0 1px 0 rgba(255, 255, 255, 0.9);
        margin-bottom: 1.25rem;
        backdrop-filter: blur(12px);
    }

    .section-title {
        font-size: 1.35rem;
        font-weight: 800;
        color: #172033;
        margin-bottom: 0.25rem;
        letter-spacing: -0.025em;
    }

    .section-caption {
        color: #64748b;
        font-size: 0.93rem;
        margin-bottom: 0.2rem;
    }

    .note-box {
        background: rgba(255, 255, 255, 0.78);
        border: 1px solid rgba(244, 114, 182, 0.16);
        border-left: 5px solid #fb7185;
        padding: 1rem 1.15rem;
        border-radius: 18px;
        color: #334155;
        font-size: 0.95rem;
        line-height: 1.6;
        box-shadow: 0 12px 28px rgba(244, 114, 182, 0.08);
    }

    .result-card {
        background: rgba(255, 255, 255, 0.82);
        padding: 1.55rem 1.65rem;
        border-radius: 26px;
        border: 1px solid rgba(244, 114, 182, 0.16);
        box-shadow:
            0 18px 44px rgba(148, 163, 184, 0.15),
            0 10px 24px rgba(244, 114, 182, 0.08);
        margin-top: 1rem;
        backdrop-filter: blur(12px);
    }

    .risk-high {
        background: linear-gradient(135deg, #fff1f2 0%, #fffbeb 100%);
        border: 1px solid #fecdd3;
        color: #9f1239;
        padding: 1rem 1.1rem;
        border-radius: 18px;
        font-weight: 650;
        line-height: 1.55;
    }

    .risk-low {
        background: linear-gradient(135deg, #ecfdf5 0%, #f0fdfa 100%);
        border: 1px solid #bbf7d0;
        color: #166534;
        padding: 1rem 1.1rem;
        border-radius: 18px;
        font-weight: 650;
        line-height: 1.55;
    }

    div[data-testid="stMetric"] {
        background: rgba(255, 255, 255, 0.82);
        padding: 1rem 1.15rem;
        border-radius: 20px;
        border: 1px solid rgba(226, 232, 240, 0.9);
        box-shadow: 0 10px 25px rgba(148, 163, 184, 0.10);
    }

    div[data-testid="stMetricValue"] {
        font-size: 2rem;
        font-weight: 850;
        color: #172033;
    }

    div[data-testid="stMetricLabel"] {
        color: #64748b;
        font-weight: 650;
    }

    .stButton > button {
        border-radius: 16px;
        padding: 0.78rem 1.18rem;
        font-weight: 800;
        border: none;
        background: linear-gradient(135deg, #fb7185 0%, #ec4899 50%, #8b5cf6 100%);
        color: white;
        box-shadow:
            0 14px 28px rgba(236, 72, 153, 0.24),
            0 8px 18px rgba(139, 92, 246, 0.12);
        transition: all 0.2s ease;
    }

    .stButton > button:hover {
        transform: translateY(-1px);
        background: linear-gradient(135deg, #f43f5e 0%, #db2777 50%, #7c3aed 100%);
        color: white;
        border: none;
        box-shadow:
            0 18px 34px rgba(236, 72, 153, 0.28),
            0 10px 20px rgba(139, 92, 246, 0.15);
    }

    .stSelectbox label, .stSlider label {
        color: #334155 !important;
        font-weight: 700 !important;
        font-size: 0.9rem !important;
    }

    div[data-baseweb="select"] > div {
        background-color: rgba(255, 255, 255, 0.82);
        border-radius: 14px;
        border: 1px solid rgba(226, 232, 240, 0.95);
        box-shadow: 0 6px 16px rgba(148, 163, 184, 0.08);
    }

    div[data-baseweb="select"] span {
        color: #1f2937;
        font-weight: 550;
    }

    [data-testid="stSlider"] {
        padding-top: 0.15rem;
    }

    [data-testid="stSlider"] > div {
        color: #be185d;
    }

    [data-testid="stSlider"] div[role="slider"] {
        background-color: #fb7185 !important;
        border: 3px solid white !important;
        box-shadow: 0 0 0 5px rgba(251, 113, 133, 0.18) !important;
    }

    [data-testid="stSlider"] div[data-testid="stTickBar"] {
        background: #fecdd3 !important;
    }

    .stProgress > div > div > div > div {
        background: linear-gradient(90deg, #fb7185 0%, #ec4899 50%, #8b5cf6 100%);
    }

    hr {
        border-color: rgba(226, 232, 240, 0.8);
    }

    .stExpander {
        border-radius: 18px !important;
        border: 1px solid rgba(226, 232, 240, 0.9) !important;
        box-shadow: 0 8px 20px rgba(148, 163, 184, 0.08);
        background: rgba(255, 255, 255, 0.8);
    }
</style>
""",
    unsafe_allow_html=True
)


# ============================================================
# Paths
# ============================================================

BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "models" / "tuned_xgboost_readmission_pipeline.pkl"
THRESHOLD_PATH = BASE_DIR / "models" / "final_threshold.pkl"


# ============================================================
# Load Artifacts
# ============================================================

@st.cache_resource
def load_artifacts():
    model = joblib.load(MODEL_PATH)
    threshold = joblib.load(THRESHOLD_PATH)
    return model, threshold


model, threshold = load_artifacts()


# ============================================================
# Feature Defaults
# ============================================================

def create_default_patient():
    return {
        "race": "Caucasian",
        "gender": "Female",
        "age": "[60-70)",

        "admission_type_id": 1,
        "discharge_disposition_id": 1,
        "admission_source_id": 7,

        "time_in_hospital": 4,
        "num_lab_procedures": 43,
        "num_procedures": 1,
        "num_medications": 16,
        "number_outpatient": 0,
        "number_emergency": 0,
        "number_inpatient": 0,
        "diag_1": "Unknown",
        "diag_2": "Unknown",
        "diag_3": "Unknown",
        "number_diagnoses": 7,

        "max_glu_serum": "Missing",
        "A1Cresult": "Missing",

        "metformin": "No",
        "repaglinide": "No",
        "nateglinide": "No",
        "chlorpropamide": "No",
        "glimepiride": "No",
        "acetohexamide": "No",
        "glipizide": "No",
        "glyburide": "No",
        "tolbutamide": "No",
        "pioglitazone": "No",
        "rosiglitazone": "No",
        "acarbose": "No",
        "miglitol": "No",
        "troglitazone": "No",
        "tolazamide": "No",
        "examide": "No",
        "citoglipton": "No",
        "insulin": "No",

        "glyburide-metformin": "No",
        "glipizide-metformin": "No",
        "glimepiride-pioglitazone": "No",
        "metformin-rosiglitazone": "No",
        "metformin-pioglitazone": "No",

        "change": "No",
        "diabetesMed": "Yes",
    }


# ============================================================
# Sidebar
# ============================================================

with st.sidebar:
    st.markdown("## 🏥 Model Overview")
    st.markdown("**Model:** Tuned XGBoost")
    st.markdown(f"**Decision threshold:** `{threshold}`")
    st.markdown("**Target:** Readmitted within 30 days")

    st.divider()

    st.markdown("### Final model snapshot")
    st.markdown(
        """
- ROC-AUC: **0.684**
- Selected threshold: **0.45**
- Positive-class recall: **0.74**
- Positive-class precision: **0.16**
"""
    )

    st.divider()

    st.markdown("### Important note")
    st.info(
        "This application is an educational ML demo. It is not intended for real clinical use."
    )


# ============================================================
# Header
# ============================================================

st.markdown(
    """
<div class="hero-card">
    <div>
        <span class="pill">Machine Learning</span>
        <span class="pill">Healthcare Analytics</span>
        <span class="pill">Educational Demo</span>
    </div>
    <div class="hero-title">Hospital Readmission<br>Risk Prediction Demo</div>
    <div class="hero-subtitle">
        Estimate the probability of 30-day hospital readmission using a tuned XGBoost model.
        The app turns a tabular ML workflow into an interactive, user-facing prototype.
    </div>
</div>
""",
    unsafe_allow_html=True
)

st.markdown(
    """
<div class="note-box">
    <b>Disclaimer:</b> This app is not a clinical decision-making tool. Predictions are produced for educational and portfolio demonstration purposes only.
</div>
""",
    unsafe_allow_html=True
)

st.write("")


# ============================================================
# Inputs
# ============================================================

st.markdown(
    """
<div class="section-card">
    <div class="section-title">Patient / Encounter Inputs</div>
    <div class="section-caption">Enter basic patient, encounter, and hospital utilization information.</div>
</div>
""",
    unsafe_allow_html=True
)

col1, col2, col3 = st.columns(3)

with col1:
    age = st.selectbox(
        "Age group",
        ["[0-10)", "[10-20)", "[20-30)", "[30-40)", "[40-50)", "[50-60)",
         "[60-70)", "[70-80)", "[80-90)", "[90-100)"],
        index=6
    )

    race = st.selectbox(
        "Race",
        ["Caucasian", "AfricanAmerican", "Hispanic", "Asian", "Other", "Unknown"],
        index=0
    )

    gender = st.selectbox(
        "Gender",
        ["Female", "Male", "Unknown/Invalid"],
        index=0
    )

    time_in_hospital = st.slider("Time in hospital", 1, 14, 4)

with col2:
    num_lab_procedures = st.slider("Number of lab procedures", 0, 130, 43)
    num_procedures = st.slider("Number of procedures", 0, 6, 1)
    num_medications = st.slider("Number of medications", 1, 80, 16)
    number_diagnoses = st.slider("Number of diagnoses", 1, 16, 7)

with col3:
    number_outpatient = st.slider("Previous outpatient visits", 0, 40, 0)
    number_emergency = st.slider("Previous emergency visits", 0, 80, 0)
    number_inpatient = st.slider("Previous inpatient visits", 0, 25, 0)


st.write("")

st.markdown(
    """
<div class="section-card">
    <div class="section-title">Admission and Treatment Context</div>
    <div class="section-caption">Add admission source, discharge context, and diabetes treatment information.</div>
</div>
""",
    unsafe_allow_html=True
)

col4, col5, col6 = st.columns(3)

with col4:
    admission_type_id = st.selectbox(
        "Admission type",
        options=[1, 2, 3, 4, 5, 6, 7, 8],
        format_func=lambda x: {
            1: "Emergency",
            2: "Urgent",
            3: "Elective",
            4: "Newborn",
            5: "Not Available",
            6: "NULL",
            7: "Trauma Center",
            8: "Not Mapped",
        }.get(x, str(x)),
        index=0
    )

    admission_source_id = st.selectbox(
        "Admission source",
        options=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 17, 20],
        format_func=lambda x: {
            1: "Physician Referral",
            2: "Clinic Referral",
            3: "HMO Referral",
            4: "Transfer from a hospital",
            5: "Transfer from SNF",
            6: "Transfer from another health care facility",
            7: "Emergency Room",
            8: "Court/Law Enforcement",
            9: "Not Available",
            10: "Transfer from critical access hospital",
            17: "NULL",
            20: "Not Mapped",
        }.get(x, str(x)),
        index=6
    )

with col5:
    discharge_disposition_id = st.selectbox(
        "Discharge disposition",
        options=[1, 2, 3, 4, 5, 6, 7, 11, 18, 25],
        format_func=lambda x: {
            1: "Discharged to home",
            2: "Transferred to another short term hospital",
            3: "Transferred to SNF",
            4: "Transferred to ICF",
            5: "Transferred to another inpatient institution",
            6: "Home with home health service",
            7: "Left AMA",
            11: "Expired",
            18: "NULL",
            25: "Not Mapped",
        }.get(x, str(x)),
        index=0
    )

    insulin = st.selectbox(
        "Insulin",
        ["No", "Steady", "Up", "Down"],
        index=0
    )

with col6:
    max_glu_serum = st.selectbox(
        "Max glucose serum",
        ["Missing", "None", "Norm", ">200", ">300"],
        index=0
    )

    a1c_result = st.selectbox(
        "A1C result",
        ["Missing", "None", "Norm", ">7", ">8"],
        index=0
    )

    change = st.selectbox(
        "Medication change",
        ["No", "Ch"],
        index=0
    )

    diabetes_med = st.selectbox(
        "Diabetes medication prescribed",
        ["No", "Yes"],
        index=1
    )


# ============================================================
# Prediction DataFrame
# ============================================================

patient_data = create_default_patient()

patient_data.update({
    "age": age,
    "race": race,
    "gender": gender,
    "admission_type_id": admission_type_id,
    "discharge_disposition_id": discharge_disposition_id,
    "admission_source_id": admission_source_id,
    "time_in_hospital": time_in_hospital,
    "num_lab_procedures": num_lab_procedures,
    "num_procedures": num_procedures,
    "num_medications": num_medications,
    "number_outpatient": number_outpatient,
    "number_emergency": number_emergency,
    "number_inpatient": number_inpatient,
    "number_diagnoses": number_diagnoses,
    "max_glu_serum": max_glu_serum,
    "A1Cresult": a1c_result,
    "insulin": insulin,
    "change": change,
    "diabetesMed": diabetes_med,
})

input_df = pd.DataFrame([patient_data])


# ============================================================
# Prediction
# ============================================================

st.write("")
st.divider()

left, right = st.columns([1, 2])

with left:
    predict_button = st.button("Predict Readmission Risk", use_container_width=True)

with right:
    st.caption(
        "The model returns a probability score. The selected threshold converts this score into a risk category."
    )

if predict_button:
    risk_probability = model.predict_proba(input_df)[:, 1][0]
    risk_label = "Higher Risk" if risk_probability >= threshold else "Lower Risk"

    st.markdown('<div class="result-card">', unsafe_allow_html=True)

    col_a, col_b, col_c = st.columns(3)

    with col_a:
        st.metric(
            label="Predicted Probability",
            value=f"{risk_probability:.2%}"
        )

    with col_b:
        st.metric(
            label="Risk Category",
            value=risk_label
        )

    with col_c:
        st.metric(
            label="Decision Threshold",
            value=f"{threshold:.2f}"
        )

    st.progress(min(float(risk_probability), 1.0))

    if risk_probability >= threshold:
        st.markdown(
            """
<div class="risk-high">
    Higher-risk classification: the predicted probability is above the selected threshold.
    This would flag the encounter for closer review in an educational screening workflow.
</div>
""",
            unsafe_allow_html=True
        )
    else:
        st.markdown(
            """
<div class="risk-low">
    Lower-risk classification: the predicted probability is below the selected threshold.
    This encounter is not flagged as high risk by the current model settings.
</div>
""",
            unsafe_allow_html=True
        )

    st.markdown("</div>", unsafe_allow_html=True)

    with st.expander("Show model input row"):
        st.dataframe(input_df, use_container_width=True)

    with st.expander("How to interpret this prediction"):
        st.markdown(
            """
- The probability represents the model's estimated risk of readmission within 30 days.
- The threshold determines when a patient is classified as higher risk.
- A lower threshold catches more high-risk patients but increases false alarms.
- A higher threshold reduces false alarms but may miss more truly readmitted patients.
"""
        )