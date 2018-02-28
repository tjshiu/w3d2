DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  student_id INTEGER NOT NULL,

  FOREIGN KEY (student_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,

  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (student_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  reply TEXT,
  questions_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  parent_id INTEGER,

  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (student_id) REFERENCES users(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,

  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (student_id) REFERENCES users(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Americo', 'Zuzunaga'), ('Drew', 'Stukey'), ('Nima', 'Partovi'), ('Yujie', 'Zhu');

INSERT INTO
  questions (title, body, student_id)
VALUES
  ('Dino''s?', 'Are dinosaurs real?', (SELECT id FROM users WHERE fname = 'Americo')),
  ('Aliens?', 'Are aliens real?', (SELECT id FROM users WHERE fname = 'Drew'));

INSERT INTO
  question_follows (questions_id, student_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Dino''s?'),
  (SELECT id FROM users WHERE fname = 'Americo' AND lname = 'Zuzunaga')),
  ((SELECT id FROM questions WHERE title = 'Aliens?'),
  (SELECT id FROM users WHERE fname = 'Drew' AND lname = 'Stukey'));

INSERT INTO
  replies (reply, questions_id, student_id, parent_id)
VALUES
  (
    'Yes, duh',
    (SELECT id FROM questions WHERE title = 'Dino''s?'),
    (SELECT id FROM users WHERE fname = 'Nima' AND lname = 'Partovi'),
    null
  ),
  (
    'The fossil record certainly is not as strong as they lead you to believe',
    (SELECT id FROM questions WHERE title = 'Dino''s?'),
    (SELECT id FROM users WHERE fname = 'Yujie' AND lname = 'Zhu'),
    -- (SELECT id FROM replies WHERE reply = 'Yes, duh')
    1
  );

INSERT INTO
  question_likes (questions_id, student_id)
VALUES
  (
    (SELECT id FROM questions WHERE title = 'Dino''s?'),
    (SELECT id FROM users WHERE fname = 'Nima' AND lname = 'Partovi')
  );
