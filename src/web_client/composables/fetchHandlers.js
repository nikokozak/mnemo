import { unref } from 'vue';

/* BLOCKS */

export async function useCreateBlock(section, type) {
    section = unref(section);

    return useSimpleFetch(`/api/blocks`, {
        method: 'POST',
        body: { 
            section_id: section.id,
            subject_id: section.subject_id,
            type
        }
    })
}

export async function useSaveBlock(block) {
    block = unref(block);

    return useSimpleFetch(`/api/blocks/${block.id}`, {
        method: 'PATCH',
        body: block
    })
}

export async function useDeleteBlock(block) {
    block = unref(block);

    return useSimpleFetch(`/api/blocks/${block.id}`, {
        method: 'DELETE'
    })
}

/* SECTIONS */

export async function useCreateSection(subject) {
    subject = unref(subject);
    return useSimpleFetch(`/api/sections`, {
        method: 'POST',
        body: { subject_id: subject.id },
    })
}

export async function useSaveSection(section) {
    section = unref(section);
    return useSimpleFetch(`/api/sections/${section.id}`, {
        method: 'PATCH',
        body: section,
    })   
}

export async function useDeleteSection(section) {
    section = unref(section);

    return useSimpleFetch(`/api/sections/${section.id}`, {
        method: 'DELETE'
    })
}

/* SUBJECTS */

export async function useCreateSubject(student) {
    student = unref(student);

    return useSimpleFetch(`/api/subjects/`, {
        method: 'POST',
        body: { student_id: student.id }
    })   
}

export async function useSaveSubject(subject) {
    subject = unref(subject);
    return useSimpleFetch(`/api/subjects/${subject.id}`, {
        method: 'PATCH',
        body: subject
    })
}

export async function useDeleteSubject(subject) {
    subject = unref(subject);
    return useSimpleFetch(`/api/subjects/${subject.id}`, {
        method: 'DELETE'
    })
}

/* ENROLLMENTS */

export async function useCreateEnrollment(student, subject) {
    subject = unref(subject);
    student = unref(student);

    return useSimpleFetch(`/api/enrollments`, {
        method: 'POST',
        body: { student_id: student.id, subject_id: subject.id }
    })
}

export async function useDeleteEnrollment(enrollment) {
    enrollment = unref(enrollment);

    return useSimpleFetch(`/api/enrollments/${enrollment.id}`, {
        method: 'DELETE',
    })
}
